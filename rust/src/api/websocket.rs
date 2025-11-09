use async_trait::async_trait;
use ezsockets::{Bytes, ClientConfig, ClientExt, Error, Utf8Bytes};
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
    pub handle: Client<WebSocketClient>,
    onTextR: Option<Box<dyn Fn(String) -> DartFnFuture<()> + Send + Sync>>,
    onBinaryR: Option<Box<dyn Fn(Vec<u8>) -> DartFnFuture<()> + Send + Sync>>,
    onConnectionFailedR: Option<Box<dyn Fn(WSError) -> DartFnFuture<()> + Send + Sync>>,
    onCloseR: Option<Box<dyn Fn(Option<CloseFrame>) -> DartFnFuture<()> + Send + Sync>>,
    onDisconnectR: Option<Box<dyn Fn() -> DartFnFuture<()> + Send + Sync>>,
}

impl WebSocketClient {
    #[flutter_rust_bridge::frb(positional)]
    pub async fn connect(url: String) {
        let config = ClientConfig::new(url.as_str());
        let _ = ezsockets::connect(
            |handle| WebSocketClient {
                handle,
                onTextR: None,
                onBinaryR: None,
                onConnectionFailedR: None,
                onCloseR: None,
                onDisconnectR: None,
            },
            config,
        )
        .await;
    }

    #[flutter_rust_bridge::frb(positional)]
    pub fn onText(&mut self, func: impl Fn(String) -> DartFnFuture<()> + Send + Sync + 'static) {
        self.onTextR = Some(Box::new(func));
    }

    #[flutter_rust_bridge::frb(positional)]
    pub fn onBinary(&mut self, func: impl Fn(Vec<u8>) -> DartFnFuture<()> + Send + Sync + 'static) {
        self.onBinaryR = Some(Box::new(func));
    }

    #[flutter_rust_bridge::frb(positional)]
    pub fn onConnectionFailed(
        &mut self,
        func: impl Fn(WSError) -> DartFnFuture<()> + Send + Sync + 'static,
    ) {
        self.onConnectionFailedR = Some(Box::new(func))
    }

    #[flutter_rust_bridge::frb(positional)]
    pub fn onClose(
        &mut self,
        func: impl Fn(Option<CloseFrame>) -> DartFnFuture<()> + Send + Sync + 'static,
    ) {
        self.onCloseR = Some(Box::new(func))
    }

    #[flutter_rust_bridge::frb(positional)]
    pub fn onDisconnect(&mut self, func: impl Fn() -> DartFnFuture<()> + Send + Sync + 'static) {
        self.onDisconnectR = Some(Box::new(func))
    }
}

#[async_trait]
impl ClientExt for WebSocketClient {
    type Call = ();

    async fn on_text(&mut self, text: Utf8Bytes) -> Result<(), Error> {
        if let Some(onT) = &self.onTextR {
            (onT)(text.as_str().to_owned()).await;
        }
        Ok(())
    }

    async fn on_binary(&mut self, bytes: Bytes) -> Result<(), Error> {
        if let Some(onB) = &self.onBinaryR {
            onB(bytes.to_vec()).await;
        }
        Ok(())
    }

    async fn on_call(&mut self, call: Self::Call) -> Result<(), Error> {
        let () = call;
        Ok(())
    }
}
