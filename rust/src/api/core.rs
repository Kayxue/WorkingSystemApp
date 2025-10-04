use anyhow::Result;
use image::{GenericImageView, ImageFormat};
use std::{fs::{metadata, read}, io::Cursor, path::Path};

pub struct ImageInformation {
    pub width: u32,
    pub height: u32,
    pub ratio: f32,
    pub format: String,
}

#[flutter_rust_bridge::frb(positional)]
pub fn get_image_information(path: String) -> Result<ImageInformation> {
    let path = Path::new(&path);

    if !path.exists() {
        return Err(anyhow::anyhow!("File does not exist"));
    }

    let img = image::open(path)?;

    let (width, height) = img.dimensions();

    let format = image::guess_format(&read(path)?)
        .map(|f| format!("{:?}", f))
        .unwrap_or("Unknown".to_string());

    Ok(ImageInformation {
        width,
        height,
        ratio: width as f32 / height as f32,
        format,
    })
}

#[flutter_rust_bridge::frb(positional)]
pub fn read_image(path: String) -> Result<Vec<u8>> {
    let path = Path::new(&path);

    if !path.exists() {
        return Err(anyhow::anyhow!("File does not exist"));
    }

    let img = image::open(path)?;
    let mut buf = Vec::new();
    let mut cursor = Cursor::new(&mut buf);
    img.write_to(&mut cursor, ImageFormat::Png)?;

    Ok(buf)
}

#[flutter_rust_bridge::frb(positional)]
pub fn get_image_name_and_size(path:String) -> Result<(String,f32)>{
    let metadata = metadata(path)?;
    let filename = Path::new(&path).file_name().map(|e| format!("{}",e.to_str())).unwrap();
    Ok(filename,((metadata.len() as f32) / 1024f32) / 1024f32)
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}
