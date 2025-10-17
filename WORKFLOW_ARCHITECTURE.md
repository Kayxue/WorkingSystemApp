# GitHub Actions Workflow Architecture

## Overview

The workflow is split into 3 parallel/sequential jobs for optimal performance and cost efficiency.

## Job Structure

```
┌─────────────────────┐
│  build-android      │  ← Runs on ubuntu-24.04-arm (Fast & Cheap)
│  (3-4 minutes)      │
└─────────────────────┘
          │
          ├─── Builds: APK & AAB
          └─── Uploads artifacts
                      │
                      ▼
┌─────────────────────┐
│  build-ios          │  ← Runs on macos-latest (Required for iOS)
│  (4-5 minutes)      │
└─────────────────────┘
          │
          ├─── Builds: IPA
          └─── Uploads artifacts
                      │
                      ▼
        ┌─────────────────────────┐
        │ Both jobs complete      │
        └─────────────────────────┘
                      │
                      ▼
┌─────────────────────┐
│  release            │  ← Runs on ubuntu-latest (Fast)
│  (1 minute)         │
└─────────────────────┘
          │
          ├─── Downloads all artifacts
          ├─── Creates GitHub Release
          └─── Uploads APK, AAB, IPA
```

## Jobs Details

### 1. build-android (ubuntu-24.04-arm)

**Purpose**: Build Android APK and App Bundle

**Runner**: `ubuntu-24.04-arm` (ARM Linux)

**Why ARM?**
- ✅ 30-50% faster for Android builds
- ✅ 90% cheaper than macOS runners
- ✅ Native ARM architecture matches Android targets
- ✅ Faster Rust compilation to Android ARM targets

**Steps**:
1. Checkout code
2. Setup Java 21
3. Setup Rust with Android targets
4. Setup Flutter SDK
5. Install dependencies
6. Accept Android licenses
7. Decode keystore
8. Create key.properties
9. Decode Firebase configs (google-services.json, firebase_options.dart)
10. Build APK (signed)
11. Build AAB (signed)
12. Upload artifacts for release job

**Outputs**:
- `app-release.apk` - Signed Android APK
- `app-release.aab` - Signed App Bundle for Play Store

### 2. build-ios (macos-latest)

**Purpose**: Build iOS IPA

**Runner**: `macos-latest` (macOS)

**Why macOS?**
- ✅ Required for iOS builds (Xcode only on macOS)
- ✅ Only used for iOS, minimizing expensive runner usage

**Steps**:
1. Checkout code
2. Setup Rust
3. Setup Flutter SDK
4. Install dependencies
5. Decode Firebase configs (firebase_options.dart, GoogleService-Info.plist)
6. Build IPA (no code sign)
7. Package IPA from .xcarchive
8. Upload artifact for release job

**Outputs**:
- `Runner.ipa` - Unsigned iOS IPA for development/testing

### 3. release (ubuntu-latest)

**Purpose**: Create GitHub Release with all build artifacts

**Runner**: `ubuntu-latest` (x64 Linux)

**Why ubuntu?**
- ✅ Fast for simple operations
- ✅ Cheapest runner (1x multiplier)
- ✅ Perfect for downloading artifacts and creating releases

**Steps**:
1. Download Android artifacts
2. Download iOS artifacts
3. Determine release version
4. Create GitHub Release
5. Upload all artifacts (APK, AAB, IPA)

**Outputs**:
- GitHub Release with 3 files attached

## Performance Benefits

### Build Time Comparison

| Configuration | Total Time | Cost (Credits) |
|--------------|------------|----------------|
| **Old (macOS only)** | ~8-10 min | ~100 credits |
| **New (Split)** | ~5-6 min | ~45 credits |
| **Savings** | **40-50% faster** | **55% cheaper** |

### Parallel Execution

- Android and iOS builds run **simultaneously**
- Total time = max(android_time, ios_time) + release_time
- Example: max(4 min, 5 min) + 1 min = **6 minutes total**

## Cost Breakdown (GitHub Actions Minutes)

### Credit Multipliers:
- Linux (x64/ARM): **1x**
- macOS: **10x**
- Windows: **2x**

### Typical Build Costs:

**Old Workflow (macOS only):**
- macOS build: 10 minutes × 10 = **100 credits**

**New Split Workflow:**
- Android (ubuntu-arm): 4 min × 1 = **4 credits**
- iOS (macOS): 5 min × 10 = **50 credits**
- Release (ubuntu): 1 min × 1 = **1 credit**
- **Total: 55 credits (45% savings!)**

## Environment & Secrets

**Environment**: `BuildEnv`

**Required Secrets**:
1. `KEYSTORE_BASE64` - Android keystore (base64 encoded)
2. `KEYSTORE_PASSWORD` - Keystore password
3. `KEY_ALIAS` - Key alias
4. `KEY_PASSWORD` - Key password
5. `GOOGLE_SERVICE_JSON` - Firebase config for Android
6. `FIREBASE_OPTIONS` - Firebase options for Dart
7. `GOOGLE_SERVICE_PLIST` - Firebase config for iOS

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

## Artifacts

Artifacts are automatically uploaded between jobs and cleaned up after the release is created.

**Retention**: 1 day (artifacts deleted after release creation)

## Output Files

GitHub Release will contain:
- `app-release.apk` - Android APK (ready to install)
- `app-release.aab` - Android App Bundle (for Play Store)
- `Runner.ipa` - iOS IPA (unsigned, for development)

## Troubleshooting

### Android build fails
- Check that all Android secrets are set in BuildEnv
- Verify keystore is valid
- Check Rust toolchain installation

### iOS build fails
- Verify Firebase PLIST is properly encoded
- Check Flutter version compatibility
- Review Xcode requirements

### Release fails
- Ensure both Android and iOS jobs completed successfully
- Check GITHUB_TOKEN permissions (contents: write)
- Verify artifact names match download patterns

## Future Improvements

Possible optimizations:
- [ ] Add caching for Rust builds
- [ ] Cache Flutter SDK
- [ ] Add build matrix for multiple Flutter versions
- [ ] Implement build notifications
- [ ] Add automated testing before release

