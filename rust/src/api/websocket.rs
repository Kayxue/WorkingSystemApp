use std::sync::{Arc};
use log::info;
use parking_lot::RwLock;

use async_trait::async_trait;
use ezsockets::client::ClientCloseMode;
use ezsockets::{Bytes, ClientConfig, ClientExt, CloseCode, Error, Utf8Bytes};
use flutter_rust_bridge::DartFnFuture;

// Re-export Client type as opaque
pub use ezsockets::Client;

// Wrapper types for flutter_rust_bridge code generation
#[derive(Debug, Clone)]
pub struct CloseFrame {
    pub code: u16,
    pub reason: String,
}

impl From<ezsockets::CloseFrame> for CloseFrame {
    fn from(frame: ezsockets::CloseFrame) -> Self {
        CloseFrame {
            code: frame.code.into(),
            reason: frame.reason.to_string(),
        }
    }
}

#[derive(Debug, Clone)]
pub struct WSError {
    pub message: String,
}

impl From<ezsockets::WSError> for WSError {
    fn from(error: ezsockets::WSError) -> Self {
        WSError {
            message: error.to_string(),
        }
    }
}

// Shared callbacks structure using Arc to allow cloning
type TextCallback = Arc<dyn Fn(String) -> DartFnFuture<()> + Send + Sync>;
type BinaryCallback = Arc<dyn Fn(Vec<u8>) -> DartFnFuture<()> + Send + Sync>;
type ErrorCallback = Arc<dyn Fn(WSError) -> DartFnFuture<()> + Send + Sync>;
type CloseCallback = Arc<dyn Fn(Option<CloseFrame>) -> DartFnFuture<()> + Send + Sync>;
type DisconnectCallback = Arc<dyn Fn() -> DartFnFuture<()> + Send + Sync>;
type ConnectCallback = Arc<dyn Fn() -> DartFnFuture<()> + Send + Sync>;

struct Callbacks {
    on_text: Option<TextCallback>,
    on_binary: Option<BinaryCallback>,
    on_connection_failed: Option<ErrorCallback>,
    on_close: Option<CloseCallback>,
    on_disconnect: Option<DisconnectCallback>,
    on_connect: Option<ConnectCallback>,
}

// Internal event handler (implements ClientExt)
struct WebSocketHandler {
    callbacks: Arc<RwLock<Callbacks>>,
}

// Public API struct that gets returned to Dart
pub struct WebSocketClient {
    handle: Arc<RwLock<Option<Client<WebSocketHandler>>>>,
    callbacks: Arc<RwLock<Callbacks>>,
}

impl WebSocketClient {
    /// Create a new WebSocketClient without connecting yet.
    /// Set up all event listeners, then call connect_to().
    #[flutter_rust_bridge::frb(sync)]
    pub fn new() -> Self {
        WebSocketClient {
            handle: Arc::new(RwLock::new(None)),
            callbacks: Arc::new(RwLock::new(Callbacks {
                on_text: None,
                on_binary: None,
                on_connection_failed: None,
                on_close: None,
                on_disconnect: None,
                on_connect: None,
            })),
        }
    }
    
    /// Connect to the WebSocket server with the pre-configured callbacks
    #[flutter_rust_bridge::frb(positional)]
    pub async fn connect_to(&self, url: String) {
        let config = ClientConfig::new(url.as_str());
        let callbacks_clone = self.callbacks.clone();
        
        let (handle, future) = ezsockets::connect(
            |_handle| WebSocketHandler {
                callbacks: callbacks_clone,
            },
            config,
        )
        .await;
        
        // Store the handle
        *self.handle.write() = Some(handle);
        
        // Spawn the future to drive the WebSocket connection in the background
        flutter_rust_bridge::spawn(async move {
            future.await.ok();
        });
    }

    #[flutter_rust_bridge::frb(positional,sync)]
    pub fn on_text(&self, func: impl Fn(String) -> DartFnFuture<()> + Send + Sync + 'static) {
        let mut callbacks = self.callbacks.write();
        callbacks.on_text = Some(Arc::new(func));
    }

    #[flutter_rust_bridge::frb(positional,sync)]
    pub fn on_binary(&self, func: impl Fn(Vec<u8>) -> DartFnFuture<()> + Send + Sync + 'static) {
        let mut callbacks = self.callbacks.write();
        callbacks.on_binary = Some(Arc::new(func));
    }

    #[flutter_rust_bridge::frb(positional,sync)]
    pub fn on_connection_failed(
        &self,
        func: impl Fn(WSError) -> DartFnFuture<()> + Send + Sync + 'static,
    ) {
        let mut callbacks = self.callbacks.write();
        callbacks.on_connection_failed = Some(Arc::new(func));
    }

    #[flutter_rust_bridge::frb(positional,sync)]
    pub fn on_close(
        &self,
        func: impl Fn(Option<CloseFrame>) -> DartFnFuture<()> + Send + Sync + 'static,
    ) {
        let mut callbacks = self.callbacks.write();
        callbacks.on_close = Some(Arc::new(func));
    }

    #[flutter_rust_bridge::frb(positional,sync)]
    pub fn on_disconnect(&self, func: impl Fn() -> DartFnFuture<()> + Send + Sync + 'static) {
        let mut callbacks = self.callbacks.write();
        callbacks.on_disconnect = Some(Arc::new(func));
    }

    #[flutter_rust_bridge::frb(positional,sync)]
    pub fn on_connect(&self, func: impl Fn() -> DartFnFuture<()> + Send + Sync + 'static) {
        info!("🦀 [Rust] Registering on_connect callback");
        let mut callbacks = self.callbacks.write();
        callbacks.on_connect = Some(Arc::new(func));
        info!("🦀 [Rust] on_connect callback registered successfully");
    }

    #[flutter_rust_bridge::frb(positional,sync)]
    pub fn send_text(&self, text: String) {
        if let Some(handle) = self.handle.read().as_ref() {
            handle.text(text.as_str()).ok();
        }
    }
}

impl Drop for WebSocketClient {
    fn drop(&mut self) {
        if let Some(handle) = self.handle.write().as_ref() {
            handle
                .close(Some(ezsockets::CloseFrame {
                    code: CloseCode::Normal,
                    reason: "User closed the connection".into(),
                }))
                .ok();
        }
    }
}

#[async_trait]
impl ClientExt for WebSocketHandler {
    type Call = ();

    async fn on_text(&mut self, text: Utf8Bytes) -> Result<(), Error> {
        info!("🦀 [Rust] on_text triggered: {}", text.as_str());
        let callback = {
            let callbacks = self.callbacks.read();
            callbacks.on_text.clone()
        };
        
        if let Some(callback) = callback {
            info!("🦀 [Rust] Invoking Dart callback for text");
            callback(text.as_str().to_owned()).await;
        } else {
            info!("🦀 [Rust] No text callback registered");
        }
        Ok(())
    }

    async fn on_binary(&mut self, bytes: Bytes) -> Result<(), Error> {
        let callback = {
            let callbacks = self.callbacks.read();
            callbacks.on_binary.clone()
        };
        
        if let Some(callback) = callback {
            callback(bytes.to_vec()).await;
        }
        Ok(())
    }

    async fn on_call(&mut self, call: Self::Call) -> Result<(), Error> {
        let () = call;
        Ok(())
    }

    async fn on_connect(&mut self) -> Result<(), Error> {
        info!("🦀 [Rust] on_connect triggered!");
        let callback = {
            let callbacks = self.callbacks.read();
            callbacks.on_connect.clone()
        };
        
        if let Some(callback) = callback {
            info!("🦀 [Rust] Invoking Dart callback for connect");
            callback().await;
            info!("🦀 [Rust] Dart callback for connect completed");
        } else {
            info!("🦀 [Rust] ⚠️ No connect callback registered!");
        }
        Ok(())
    }

    async fn on_connect_fail(
        &mut self,
        error: ezsockets::WSError,
    ) -> Result<ClientCloseMode, Error> {
        info!("🦀 [Rust] on_connect_fail triggered: {}", error);
        let callback = {
            let callbacks = self.callbacks.read();
            callbacks.on_connection_failed.clone()
        };
        
        if let Some(callback) = callback {
            info!("🦀 [Rust] Invoking Dart callback for connection failed");
            callback(error.into()).await;
        } else {
            info!("🦀 [Rust] No connection_failed callback registered");
        }
        Ok(ClientCloseMode::Close)
    }

    async fn on_close(
        &mut self,
        frame: Option<ezsockets::CloseFrame>,
    ) -> Result<ClientCloseMode, Error> {
        let reason = frame.as_ref().map(|f| f.reason.as_ref()).unwrap_or("None");
        info!("🦀 [Rust] on_close triggered: {}", reason);
        let callback = {
            let callbacks = self.callbacks.read();
            callbacks.on_close.clone()
        };
        
        if let Some(callback) = callback {
            info!("🦀 [Rust] Invoking Dart callback for close");
            callback(frame.map(|f| f.into())).await;
        } else {
            info!("🦀 [Rust] No close callback registered");
        }
        Ok(ClientCloseMode::Close)
    }
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}