# GitHub Actions Workflow Architecture

## Overview

The workflow is split into 3 sequential jobs for optimal performance and cost efficiency, building Android and iOS apps in parallel, then creating a unified release.

## Job Structure

```
┌─────────────────────┐
│  build-android      │  ← Runs on ubuntu-latest (Standard & Reliable)
│  (3-5 minutes)      │
└─────────────────────┘
          │
          ├─── Builds: Split APKs (arm64-v8a, armeabi-v7a) & AAB
          └─── Uploads artifacts
                      │
                      ▼
┌─────────────────────┐
│  build-ios          │  ← Runs on macos-latest (Required for iOS)
│  (4-6 minutes)      │
└─────────────────────┘
          │
          ├─── Builds: IPA (unsigned)
          └─── Uploads artifacts
                      │
                      ▼
        ┌─────────────────────────┐
        │ Both jobs complete      │
        └─────────────────────────┘
                      │
                      ▼
┌─────────────────────┐
│  release            │  ← Runs on ubuntu-24.04-arm (Fast & Efficient)
│  (1-2 minutes)      │
└─────────────────────┘
          │
          ├─── Downloads all artifacts
          ├─── Renames files with version
          ├─── Creates GitHub Release
          └─── Uploads APK (x2), AAB, IPA
```

## Jobs Details

### 1. build-android (ubuntu-latest)

**Purpose**: Build Android APK and App Bundle with ABI splits

**Runner**: `ubuntu-latest` (x64 Linux)

**Why ubuntu-latest?**
- ✅ Stable and well-supported
- ✅ Good performance for Android builds
- ✅ Cheap compared to macOS (1x cost multiplier)
- ✅ Sufficient for Rust + Flutter Android builds

**Steps**:
1. **Maximize build space** - Removes unused tools (.NET, Haskell, CodeQL, Docker images)
2. Checkout code
3. Setup Java 21 (Temurin distribution)
4. Setup Android SDK
5. Setup Rust with Android targets (aarch64-linux-android, armv7-linux-androideabi)
6. Setup Flutter SDK (stable channel)
7. Run flutter doctor
8. Install dependencies (flutter pub get)
9. Decode keystore from base64
10. Create key.properties with signing credentials
11. Decode Firebase configs (google-services.json, firebase_options.dart)
12. **Build APK** - Split per ABI (arm64-v8a, armeabi-v7a)
13. **Build AAB** - Release bundle for Play Store
14. Verify build outputs (APK count, AAB existence)
15. Upload artifacts for release job

**Outputs**:
- `app-armeabi-v7a-release.apk` - Signed APK for ARM 32-bit devices
- `app-arm64-v8a-release.apk` - Signed APK for ARM 64-bit devices
- `app-release.aab` - Signed App Bundle for Play Store

**Build Commands**:
```bash
flutter build apk --release --split-per-abi \
  --target-platform android-arm,android-arm64 \
  --build-name="${VERSION}" \
  --build-number="${RUN_NUMBER}"

flutter build appbundle --release \
  --target-platform android-arm,android-arm64 \
  --build-name="${VERSION}" \
  --build-number="${RUN_NUMBER}"
```

### 2. build-ios (macos-latest)

**Purpose**: Build iOS IPA (unsigned)

**Runner**: `macos-latest` (macOS)

**Why macOS?**
- ✅ Required for iOS builds (Xcode only on macOS)
- ✅ Only used for iOS, minimizing expensive runner usage
- ✅ Latest stable macOS with up-to-date Xcode

**Steps**:
1. Checkout code
2. Setup Rust with iOS target (aarch64-apple-ios)
3. Setup Flutter SDK (stable channel, latest version)
4. Install dependencies (flutter pub get)
5. Decode Firebase configs (firebase_options.dart, GoogleService-Info.plist)
6. **Clean iOS build** - Remove Pods, Podfile.lock, clear caches
7. **Build IPA** - Release mode, no code signing
8. **Package IPA from .xcarchive** - Extract Runner.app, create Payload, zip as IPA
9. Upload artifact for release job

**Outputs**:
- `Runner.ipa` - Unsigned iOS IPA for development/testing/distribution

**Build Commands**:
```bash
# Clean
cd ios && rm -rf Pods Podfile.lock && pod cache clean --all
flutter clean

# Build
flutter build ipa --release --no-codesign \
  --build-name="${VERSION}" \
  --build-number="${RUN_NUMBER}"

# Package
cd build/ios/archive
mkdir -p Payload
cp -r *.xcarchive/Products/Applications/Runner.app Payload/
zip -r Runner.ipa Payload
```

### 3. release (ubuntu-24.04-arm)

**Purpose**: Create GitHub Release with all build artifacts

**Runner**: `ubuntu-24.04-arm` (ARM64 Linux)

**Why ubuntu-24.04-arm?**
- ✅ Fast for file operations and artifact management
- ✅ Cheapest runner (1x multiplier)
- ✅ Perfect for downloading artifacts and creating releases
- ✅ ARM architecture for optimal performance-to-cost ratio

**Steps**:
1. Download Android artifacts (uses actions/download-artifact@v5)
2. Download iOS artifacts (uses actions/download-artifact@v5)
3. Verify downloaded artifacts (check APK, AAB, IPA existence)
4. Determine release version (from tag or workflow_dispatch input)
5. **Prepare release files** - Rename with repository name and version:
   - `{repo}-{version}-armeabi-v7a.apk`
   - `{repo}-{version}-arm64-v8a.apk`
   - `{repo}-{version}.aab`
   - `{repo}-{version}.ipa`
6. Create GitHub Release with proper naming
7. Upload all renamed artifacts

**Outputs**:
- GitHub Release with 4 files attached (2 APKs, 1 AAB, 1 IPA)

**File Naming Convention**:
```
WorkingSystemApp-v1.0.0-armeabi-v7a.apk
WorkingSystemApp-v1.0.0-arm64-v8a.apk
WorkingSystemApp-v1.0.0.aab
WorkingSystemApp-v1.0.0.ipa
```

## Performance Benefits

### Build Time Comparison

| Configuration | Total Time | Cost (Credits) |
|--------------|------------|----------------|
| **Old (macOS only)** | ~10-12 min | ~120 credits |
| **New (Split)** | ~6-8 min | ~62 credits |
| **Savings** | **40-50% faster** | **48% cheaper** |

### Parallel Execution

- Android and iOS builds run **simultaneously**
- Total time = max(android_time, ios_time) + release_time
- Example: max(5 min, 6 min) + 2 min = **8 minutes total**

## Cost Breakdown (GitHub Actions Minutes)

### Credit Multipliers:
- Linux (x64/ARM): **1x**
- macOS: **10x**
- Windows: **2x**

### Typical Build Costs:

**Old Workflow (macOS only):**
- macOS build: 12 minutes × 10 = **120 credits**

**New Split Workflow:**
- Android (ubuntu-latest): 5 min × 1 = **5 credits**
- iOS (macOS-latest): 6 min × 10 = **60 credits**
- Release (ubuntu-arm): 2 min × 1 = **2 credits**
- **Total: 67 credits (44% savings!)**

## Environment & Secrets

**Environment**: `BuildEnv`

**Required Secrets**:
1. `KEYSTORE_BASE64` - Android keystore (base64 encoded)
2. `KEYSTORE_PASSWORD` - Keystore password
3. `KEY_ALIAS` - Key alias for signing
4. `KEY_PASSWORD` - Key password
5. `GOOGLE_SERVICE_JSON` - Firebase config for Android (base64)
6. `FIREBASE_OPTIONS` - Firebase options for Dart (base64)
7. `GOOGLE_SERVICE_PLIST` - Firebase config for iOS (base64)
8. `RELEASE_PAT` - Personal Access Token for creating releases

## Triggers

### Automatic (Tag Push):
```bash
git tag v1.0.0
git push origin v1.0.0
```

### Manual (Workflow Dispatch):
1. Go to Actions tab
2. Select "Build & Release"
3. Click "Run workflow"
4. Enter version (e.g., v1.0.0)
5. Click "Run workflow" button

## Build Configuration

### Android Build Options
- **Split per ABI**: Generates separate APKs for different architectures
- **Target Platforms**: android-arm (32-bit), android-arm64 (64-bit)
- **Signed**: Yes, using keystore credentials
- **Build Name**: Version from tag or input
- **Build Number**: GitHub run number

### iOS Build Options
- **Code Signing**: Disabled (--no-codesign)
- **Target**: aarch64-apple-ios (ARM64)
- **Build Name**: Version from tag or input
- **Build Number**: GitHub run number
- **Clean Build**: Yes (removes pods and caches)

## Artifacts

Artifacts are automatically managed between jobs:

**Retention**: 1 day (artifacts deleted after 24 hours)

**Android Artifacts** (`android-builds`):
- All APK files from flutter-apk output
- AAB file from bundle/release output

**iOS Artifacts** (`ios-builds`):
- Runner.ipa file

## Output Files

GitHub Release will contain:
- `{repo}-{version}-armeabi-v7a.apk` - Android APK for 32-bit ARM
- `{repo}-{version}-arm64-v8a.apk` - Android APK for 64-bit ARM
- `{repo}-{version}.aab` - Android App Bundle (for Play Store)
- `{repo}-{version}.ipa` - iOS IPA (unsigned, for development/TestFlight)

## Space Optimization

### Android Build Space Cleanup
The workflow automatically removes unused tools to free up disk space:
- ❌ .NET SDKs (~3-4 GB)
- ❌ Haskell/GHC/Cabal (~2-3 GB)
- ❌ CodeQL tools (~1-2 GB)
- ❌ Docker images (~5-10 GB)

This prevents "No space left on device" errors during large builds.

## Troubleshooting

### Android build fails

**"No space left on device":**
- The "Maximize build space" step should handle this
- Check if cleanup steps executed successfully

**Keystore errors:**
- Verify KEYSTORE_BASE64 is properly encoded: `base64 -w 0 keystore.jks`
- Check KEYSTORE_PASSWORD, KEY_ALIAS, KEY_PASSWORD are correct
- Ensure keystore file is valid and not corrupted

**Firebase configuration errors:**
- Verify GOOGLE_SERVICE_JSON is properly base64 encoded
- Check FIREBASE_OPTIONS is correctly formatted
- Ensure files decode successfully in the workflow logs

**Rust compilation errors:**
- Check Rust targets are properly installed
- Verify Android NDK is available
- Review Flutter/Rust bridge compatibility

### iOS build fails

**Pod installation errors:**
- The clean step should handle most pod issues
- Check if CocoaPods version is compatible
- Review Podfile.lock for conflicts

**Firebase PLIST errors:**
- Verify GOOGLE_SERVICE_PLIST is properly base64 encoded
- Ensure file structure is valid XML/plist format
- Check if file is placed in correct location (ios/Runner/)

**Archive packaging errors:**
- Verify .xcarchive was created successfully
- Check if Runner.app exists in archive Products
- Review zip command execution logs

**Flutter/Xcode version issues:**
- Ensure Flutter stable channel is compatible with latest Xcode
- Check flutter-actions/setup-flutter action logs
- Review Xcode command line tools installation

### Release fails

**Artifact not found:**
- Ensure both Android and iOS jobs completed successfully
- Check artifact names match exactly in upload/download steps
- Verify retention period hasn't expired (24 hours)

**Permission denied:**
- Check RELEASE_PAT token has correct permissions (repo, write:packages)
- Verify token hasn't expired
- Ensure BuildEnv environment allows access

**File not found during upload:**
- Review "Prepare Release Files" step logs
- Verify APK/AAB/IPA files were copied correctly
- Check file naming pattern matches in create release step

**Duplicate release:**
- Delete existing release/tag with same version
- Or use different version number

## Permissions

The workflow requires:
```yaml
permissions:
  contents: write  # For creating releases and uploading assets
```

Additionally, `RELEASE_PAT` must have:
- `repo` scope (full repository access)
- `write:packages` scope (for artifacts/releases)

## Future Improvements

Possible optimizations:
- [ ] Add caching for Rust builds (~30% faster)
- [ ] Cache Flutter SDK and pub dependencies (~20% faster)
- [ ] Cache Gradle dependencies for Android (~15% faster)
- [ ] Add build matrix for multiple Flutter versions
- [ ] Implement automated testing before release
- [ ] Add build notifications (Slack, Discord, Email)
- [ ] Generate release notes from commits
- [ ] Add checksum verification for artifacts
- [ ] Implement incremental builds
- [ ] Add code signing for iOS (requires Apple Developer account)

## Version Management

**Version Format**: `v{major}.{minor}.{patch}` (e.g., v1.0.0)

**Build Number**: Automatically set to GitHub run number

**Version Sources**:
1. **Tag Push**: Uses tag name as version
2. **Manual Dispatch**: Uses input version parameter

**Example**:
```bash
# Tag-based release
git tag v1.2.3
git push origin v1.2.3

# Manual release via GitHub UI
# Input: v1.2.4
```

Both result in build name `v1.2.x` and build number from GitHub run counter.
