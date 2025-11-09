use async_trait::async_trait;
use ezsockets::{Bytes, Client, ClientConfig, ClientExt, CloseFrame, Error, Utf8Bytes, WSError};
use flutter_rust_bridge::DartFnFuture;

pub struct WebSocketClient {
    pub handle: Client<WebSocketClient>,
    onTextR: Option<Box<dyn Fn(String) -> DartFnFuture<()> + Send + Sync>>,
    onBinaryR: Option<Box<dyn Fn(Vec<u8>) -> DartFnFuture<()> + Send + Sync>>,
    onConnectionFailedR: Option<Box<dyn Fn(WSError) -> DartFnFuture<()> + Send + Sync>>,
    onClose: Option<Box<dyn Fn(Option<CloseFrame>) -> DartFnFuture<()> + Send + Sync>>,
    onDisconnect: Option<Box<dyn Fn() -> DartFnFuture<()> + Send + Sync>>,
}

impl WebSocketClient {
    #[flutter_rust_bridge::frb(positional)]
    pub async fn connect(url: String) {
        let config = ClientConfig::new(url.as_str());
        ezsockets::connect(
            |handle| WebSocketClient {
                handle,
                onTextR: None,
                onBinaryR: None,
                onConnectionFailedR: None,
                onClose: None,
                onDisconnect: None,
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
        self.onClose = Some(Box::new(func))
    }

    #[flutter_rust_bridge::frb(positional)]
    pub fn onDisconnect(&mut self, func: impl Fn() -> DartFnFuture<()> + Send + Sync + 'static) {
        self.onDisconnect = Some(Box::new(func))
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
            onB(bytes.to_vec()).await
        }
        Ok(())
    }

    async fn on_call(&mut self, call: Self::Call) -> Result<(), Error> {
        let () = call;
        Ok(())
    }
}
