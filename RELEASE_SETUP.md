# Release Setup Instructions

This document explains how to set up automated APK releases using GitHub Actions.

## Prerequisites

1. **Android Keystore**: You need a keystore file for signing the APK
2. **GitHub Repository Secrets**: Required secrets must be configured

## GitHub Secrets Configuration

Go to your repository Settings → Secrets and variables → Actions, and add these secrets:

### Required Secrets

#### Keystore Secrets (for APK signing)

1. **KEYSTORE_BASE64**
   - Base64 encoded version of your keystore file
   - Generate with: `base64 -i keystore.jks | pbcopy` (macOS) or `base64 keystore.jks | xclip -selection clipboard` (Linux)

2. **KEYSTORE_PASSWORD**
   - Password for the keystore file

3. **KEY_ALIAS**
   - Alias name of the key in the keystore

4. **KEY_PASSWORD**
   - Password for the specific key alias

#### Firebase Secrets (for Firebase functionality)

5. **GOOGLE_SERVICE_JSON**
   - Base64 encoded version of `android/app/google-services.json`
   - Generate with: `base64 -i android/app/google-services.json | tr -d '\n' | pbcopy`
   - **Important**: Remove all newlines from the base64 string

6. **FIREBASE_OPTIONS**
   - Base64 encoded version of `lib/firebase_options.dart`
   - Generate with: `base64 -i lib/firebase_options.dart | tr -d '\n' | pbcopy`
   - **Important**: Remove all newlines from the base64 string

7. **GOOGLE_SERVICE_PLIST**
   - Base64 encoded version of `ios/Runner/GoogleService-Info.plist`
   - Generate with: `base64 -i ios/Runner/GoogleService-Info.plist | tr -d '\n' | pbcopy`
   - **Important**: Remove all newlines from the base64 string

**Note**: When pasting secrets into GitHub, ensure there are NO extra spaces, newlines, or quotes around the base64 string. The secret should be a single continuous string of base64 characters.

## How to Create a Keystore (if you don't have one)

```bash
keytool -genkey -v -keystore keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

Follow the prompts to set passwords and information.

## Triggering a Release

### Method 1: Git Tags (Recommended)
```bash
git tag v1.0.0
git push origin v1.0.0
```

### Method 2: Manual Workflow Dispatch
1. Go to Actions tab in your GitHub repository
2. Select "Build & Release" workflow
3. Click "Run workflow"
4. Enter the version number (e.g., v1.0.0)
5. Click "Run workflow"

## What the Workflow Does

1. **Sets up build environment**:
   - Java 21
   - Rust toolchain with Android targets
   - Android NDK
   - Flutter SDK

2. **Prepares configuration**:
   - Decodes keystore from base64
   - Creates key.properties file
   - Decodes Firebase configuration files (google-services.json, firebase_options.dart, GoogleService-Info.plist)

3. **Builds the app**:
   - Generates Rust bridge code
   - Builds release APK (Android)
   - Builds App Bundle (AAB for Google Play)
   - Builds iOS IPA (unsigned, for development/testing)

4. **Creates GitHub Release**:
   - Creates a new release with the specified version
   - Uploads APK, AAB, and IPA files as release assets

## Output Files

The workflow generates:
- `app-release.apk` - Signed APK for direct installation on Android devices
- `app-release.aab` - App Bundle for Google Play Store submission
- `Runner.ipa` - Unsigned iOS IPA for development/testing (cannot be installed on production devices)

## Troubleshooting

### Common Issues

1. **Keystore decode fails**: Ensure KEYSTORE_BASE64 secret is properly encoded
2. **Signing fails**: Check that all keystore-related secrets are correct
3. **Rust build fails**: Ensure your Rust code compiles locally first
4. **NDK issues**: The workflow uses the latest available NDK on the runner
5. **Firebase configuration missing**: Ensure all Firebase secrets are properly set
6. **iOS IPA cannot be installed**: The IPA is unsigned and is for development/testing only. To install on devices, you need to sign it with a provisioning profile

### Testing Locally

Before pushing a tag, test the build locally:

```bash
# Install flutter_rust_bridge_codegen
dart pub global activate flutter_rust_bridge_codegen

# Generate Rust bridge
dart pub global run flutter_rust_bridge_codegen generate

# Build APK
flutter build apk --release
```

## Security Notes

- Never commit keystore files or passwords to the repository
- Use GitHub secrets for all sensitive information
- The keystore.jks file in the root is ignored by git (check .gitignore)
- Consider using different keystores for debug and release builds
