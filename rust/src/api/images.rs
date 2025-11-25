use anyhow::Result;
use image::ImageFormat;
use std::{
    fs::metadata,
    io::Cursor,
    path::{Path, PathBuf},
};

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
pub fn get_image_name_and_size(path: String) -> Result<(String, f32)> {
    let metadata = metadata(&path)?;
    let filename = Path::new(&path)
        .file_name()
        .map(|e| format!("{}", e.to_str().unwrap()))
        .unwrap();
    Ok((filename, ((metadata.len() as f32) / 1024f32) / 1024f32))
}

#[flutter_rust_bridge::frb(positional)]
pub fn change_filename_extension(filename: String, extension: String) -> String {
    let mut buf = PathBuf::from(filename);
    buf.set_extension(extension);
    buf.to_str().unwrap().to_string()
}
