#[flutter_rust_bridge::frb(positional, sync)]
pub fn get_name_to_display(first_name: String, last_name: String) -> String {
    // Check if the name contains Chinese characters
    let has_chinese = |s: &str| -> bool {
        s.chars().any(|c| {
            // CJK Unified Ideographs range
            ('\u{4E00}'..='\u{9FFF}').contains(&c) ||
            // CJK Unified Ideographs Extension A
            ('\u{3400}'..='\u{4DBF}').contains(&c) ||
            // CJK Compatibility Ideographs
            ('\u{F900}'..='\u{FAFF}').contains(&c)
        })
    };

    // If either name contains Chinese characters, use Chinese format (LastName + FirstName)
    // Otherwise use English format (FirstName + LastName with space)
    if has_chinese(&first_name) || has_chinese(&last_name) {
        // Chinese format: last name first, no space
        format!("{}{}", last_name, first_name)
    } else {
        // English format: first name first, with space
        format!("{} {}", first_name, last_name)
    }
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}