use email_address::EmailAddress;

#[flutter_rust_bridge::frb(positional, sync)]
pub fn is_valid_email(email: String) -> bool {
    EmailAddress::is_valid(&email)
}
