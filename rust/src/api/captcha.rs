use captcha::{
    filters::{Dots, Noise, Wave},
    Captcha,
};
use log::info;

#[flutter_rust_bridge::frb(positional)]
pub fn generate_captcha() -> (Vec<u8>, String) {
    info!("Generating captcha...");
    let mut captcha = Captcha::new();
    captcha.add_chars(5);
    captcha.apply_filter(Noise::new(0.4));
    captcha.apply_filter(Wave::new(2.0, 20.0).horizontal());
    captcha.apply_filter(Wave::new(2.0, 20.0).vertical());
    captcha.view(220, 120);
    let captcha = captcha.apply_filter(Dots::new(10));
    info!("Generated captcha with solution: {}", captcha.chars_as_string());
    let solution = captcha.chars_as_string().to_string();
    let captcha_png = captcha.as_png().unwrap();

    (captcha_png, solution)
}
