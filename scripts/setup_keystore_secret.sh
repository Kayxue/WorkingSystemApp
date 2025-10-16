#!/bin/bash

# Script to help set up secrets for GitHub Actions
# This script generates base64 encoded files for GitHub secrets

set -e

KEYSTORE_FILE="keystore.jks"
GOOGLE_SERVICES_JSON="android/app/google-services.json"
FIREBASE_OPTIONS="lib/firebase_options.dart"
GOOGLE_SERVICE_PLIST="ios/Runner/GoogleService-Info.plist"

echo "🔐 GitHub Actions Secrets Setup"
echo "==============================="

# Check if keystore exists
if [ ! -f "$KEYSTORE_FILE" ]; then
    echo "❌ Keystore file '$KEYSTORE_FILE' not found in current directory"
    echo ""
    echo "To create a new keystore, run:"
    echo "keytool -genkey -v -keystore keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key"
    echo ""
    exit 1
fi

echo "✅ Found keystore file: $KEYSTORE_FILE"
echo ""

# Generate base64 encodings
echo "📝 Generating base64 encodings for GitHub secrets..."
echo ""

# Keystore
KEYSTORE_BASE64=$(base64 -i "$KEYSTORE_FILE")
echo "✅ Keystore encoded"

# Firebase files
FIREBASE_SECRETS=""
if [ -f "$GOOGLE_SERVICES_JSON" ]; then
    GOOGLE_SERVICE_JSON_BASE64=$(base64 -i "$GOOGLE_SERVICES_JSON")
    FIREBASE_SECRETS="${FIREBASE_SECRETS}✅ Google Services JSON encoded\n"
else
    echo "⚠️  Warning: $GOOGLE_SERVICES_JSON not found"
fi

if [ -f "$FIREBASE_OPTIONS" ]; then
    FIREBASE_OPTIONS_BASE64=$(base64 -i "$FIREBASE_OPTIONS")
    FIREBASE_SECRETS="${FIREBASE_SECRETS}✅ Firebase Options encoded\n"
else
    echo "⚠️  Warning: $FIREBASE_OPTIONS not found"
fi

if [ -f "$GOOGLE_SERVICE_PLIST" ]; then
    GOOGLE_SERVICE_PLIST_BASE64=$(base64 -i "$GOOGLE_SERVICE_PLIST")
    FIREBASE_SECRETS="${FIREBASE_SECRETS}✅ Google Service Plist encoded\n"
else
    echo "⚠️  Warning: $GOOGLE_SERVICE_PLIST not found"
fi

echo -e "$FIREBASE_SECRETS"
echo ""
echo "🔑 GitHub Secrets Setup:"
echo "========================"
echo ""
echo "Go to your GitHub repository → Settings → Secrets and variables → Actions"
echo "Add the following secrets:"
echo ""

# Keystore secrets
echo "📱 KEYSTORE SECRETS:"
echo "-------------------"
echo "1. KEYSTORE_BASE64:"
echo "$KEYSTORE_BASE64"
echo ""
echo "2. KEYSTORE_PASSWORD: [Your keystore password]"
echo "3. KEY_ALIAS: [Your key alias, probably 'key']"
echo "4. KEY_PASSWORD: [Your key password]"
echo ""

# Firebase secrets
echo "🔥 FIREBASE SECRETS:"
echo "-------------------"
if [ -f "$GOOGLE_SERVICES_JSON" ]; then
    echo "5. GOOGLE_SERVICE_JSON:"
    echo "$GOOGLE_SERVICE_JSON_BASE64"
    echo ""
fi

if [ -f "$FIREBASE_OPTIONS" ]; then
    echo "6. FIREBASE_OPTIONS:"
    echo "$FIREBASE_OPTIONS_BASE64"
    echo ""
fi

if [ -f "$GOOGLE_SERVICE_PLIST" ]; then
    echo "7. GOOGLE_SERVICE_PLIST:"
    echo "$GOOGLE_SERVICE_PLIST_BASE64"
    echo ""
fi
echo ""
echo "💡 Tip: The base64 content has been copied to clipboard (if pbcopy is available)"

# Try to copy to clipboard if available
if command -v pbcopy >/dev/null 2>&1; then
    echo "$KEYSTORE_BASE64" | pbcopy
    echo "✅ Keystore base64 content copied to clipboard!"
elif command -v xclip >/dev/null 2>&1; then
    echo "$KEYSTORE_BASE64" | xclip -selection clipboard
    echo "✅ Keystore base64 content copied to clipboard!"
else
    echo "📋 Manual copy required - clipboard tool not available"
fi

echo ""
echo "🚀 Once secrets are set up, create a release with:"
echo "   git tag v1.0.0"
echo "   git push origin v1.0.0"
echo ""
echo "Or use the manual workflow dispatch in GitHub Actions tab."
