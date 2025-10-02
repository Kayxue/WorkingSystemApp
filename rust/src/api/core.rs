#[flutter_rust_bridge::frb(positional)]
pub fn get_image_information(path:String) -> String {
    unimplemented!()
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}
