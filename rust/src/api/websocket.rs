use std::sync::Arc;

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

pub struct WebSocketClient {
    handle: Arc<Client<WebSocketClient>>,
    on_text_r: Option<Box<dyn Fn(String) -> DartFnFuture<()> + Send + Sync>>,
    on_binary_r: Option<Box<dyn Fn(Vec<u8>) -> DartFnFuture<()> + Send + Sync>>,
    on_connection_failed_r: Option<Box<dyn Fn(WSError) -> DartFnFuture<()> + Send + Sync>>,
    on_close_r: Option<Box<dyn Fn(Option<CloseFrame>) -> DartFnFuture<()> + Send + Sync>>,
    on_disconnect_r: Option<Box<dyn Fn() -> DartFnFuture<()> + Send + Sync>>,
}

impl WebSocketClient {
    #[flutter_rust_bridge::frb(positional)]
    pub async fn connect(url: String) {
        let config = ClientConfig::new(url.as_str());
        let _ = ezsockets::connect(
            |handle| WebSocketClient {
                handle: Arc::new(handle),
                on_text_r: None,
                on_binary_r: None,
                on_connection_failed_r: None,
                on_close_r: None,
                on_disconnect_r: None,
            },
            config,
        )
        .await;
    }

    #[flutter_rust_bridge::frb(positional)]
    pub fn on_text(&mut self, func: impl Fn(String) -> DartFnFuture<()> + Send + Sync + 'static) {
        self.on_text_r = Some(Box::new(func));
    }

    #[flutter_rust_bridge::frb(positional)]
    pub fn on_binary(&mut self, func: impl Fn(Vec<u8>) -> DartFnFuture<()> + Send + Sync + 'static) {
        self.on_binary_r = Some(Box::new(func));
    }

    #[flutter_rust_bridge::frb(positional)]
    pub fn on_connection_failed(
        &mut self,
        func: impl Fn(WSError) -> DartFnFuture<()> + Send + Sync + 'static,
    ) {
        self.on_connection_failed_r = Some(Box::new(func))
    }

    #[flutter_rust_bridge::frb(positional)]
    pub fn on_close(
        &mut self,
        func: impl Fn(Option<CloseFrame>) -> DartFnFuture<()> + Send + Sync + 'static,
    ) {
        self.on_close_r = Some(Box::new(func))
    }

    #[flutter_rust_bridge::frb(positional)]
    pub fn on_disconnect(&mut self, func: impl Fn() -> DartFnFuture<()> + Send + Sync + 'static) {
        self.on_disconnect_r = Some(Box::new(func))
    }

    #[flutter_rust_bridge::frb(positional)]
    pub async fn send_text(&self, text: String){
        self.handle.text(text.as_str()).ok();
    }
}

impl Drop for WebSocketClient {
    fn drop(&mut self) {
        self.handle
            .close(Some(ezsockets::CloseFrame {
                code: CloseCode::Normal,
                reason: "User closed the connection".into(),
            }))
            .ok();
    }
}

#[async_trait]
impl ClientExt for WebSocketClient {
    type Call = ();

    async fn on_text(&mut self, text: Utf8Bytes) -> Result<(), Error> {
        if let Some(onT) = &self.on_text_r {
            (onT)(text.as_str().to_owned()).await;
        }
        Ok(())
    }

    async fn on_binary(&mut self, bytes: Bytes) -> Result<(), Error> {
        if let Some(onB) = &self.on_binary_r {
            onB(bytes.to_vec()).await;
        }
        Ok(())
    }

    async fn on_call(&mut self, call: Self::Call) -> Result<(), Error> {
        let () = call;
        Ok(())
    }

    async fn on_connect(&mut self) -> Result<(), Error> {
        let handle = self.handle.clone();
        //TODO: Send Authentication content
        Ok(())
    }

    async fn on_connect_fail(
        &mut self,
        error: ezsockets::WSError,
    ) -> Result<ClientCloseMode, Error> {
        if let Some(onCF) = &self.on_connection_failed_r {
            (onCF)(error.into()).await;
        }
        Ok(ClientCloseMode::Close)
    }
}
