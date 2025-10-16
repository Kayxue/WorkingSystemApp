#!/bin/bash

# Script to encode Firebase files and verify they decode correctly

set -e

echo "🔥 Firebase Secrets Encoder & Verifier"
echo "======================================"
echo ""

GOOGLE_SERVICES_JSON="android/app/google-services.json"
FIREBASE_OPTIONS="lib/firebase_options.dart"
GOOGLE_SERVICE_PLIST="ios/Runner/GoogleService-Info.plist"

# Function to encode and verify
encode_and_verify() {
    local file=$1
    local name=$2
    
    if [ ! -f "$file" ]; then
        echo "❌ $file not found"
        return 1
    fi
    
    echo "📄 Processing: $file"
    
    # Encode
    local encoded=$(base64 -i "$file" | tr -d '\n')
    
    # Verify by decoding and writing to temp file
    local temp_file=$(mktemp)
    echo -n "$encoded" | base64 --decode > "$temp_file"
    
    # Compare files using diff
    local original_size=$(wc -c < "$file" | tr -d ' ')
    local decoded_size=$(wc -c < "$temp_file" | tr -d ' ')
    
    echo "   Original size: $original_size bytes"
    echo "   Decoded size:  $decoded_size bytes"
    
    # Check if files are identical (using cmp instead of size comparison)
    if cmp -s "$file" "$temp_file"; then
        echo "   ✅ Verification successful!"
        echo ""
        echo "   Secret name: $name"
        echo "   Base64 value (first 50 chars): ${encoded:0:50}..."
        echo "   Full length: ${#encoded} characters"
        echo ""
        rm -f "$temp_file"
        return 0
    else
        echo "   ❌ Verification failed! Files don't match"
        echo "   Size difference: $((original_size - decoded_size)) bytes"
        
        # Show file comparison for debugging
        echo "   Showing differences:"
        diff "$file" "$temp_file" || echo "   Files differ"
        
        rm -f "$temp_file"
        
        echo ""
        echo "   ⚠️  Warning: Encoding/decoding may have issues"
        echo "   The secret might still work, but verify carefully"
        echo ""
        read -p "   Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            return 0
        else
            return 1
        fi
    fi
}

echo "Encoding and verifying files..."
echo ""

# Process each file
encode_and_verify "$GOOGLE_SERVICES_JSON" "GOOGLE_SERVICE_JSON"
GOOGLE_SERVICE_JSON_BASE64=$(base64 -i "$GOOGLE_SERVICES_JSON" | tr -d '\n')

encode_and_verify "$FIREBASE_OPTIONS" "FIREBASE_OPTIONS"
FIREBASE_OPTIONS_BASE64=$(base64 -i "$FIREBASE_OPTIONS" | tr -d '\n')

encode_and_verify "$GOOGLE_SERVICE_PLIST" "GOOGLE_SERVICE_PLIST"
GOOGLE_SERVICE_PLIST_BASE64=$(base64 -i "$GOOGLE_SERVICE_PLIST" | tr -d '\n')

echo "======================================"
echo "📋 GitHub Secrets to Add:"
echo "======================================"
echo ""
echo "1. GOOGLE_SERVICE_JSON"
echo "   Length: ${#GOOGLE_SERVICE_JSON_BASE64} chars"
if command -v pbcopy >/dev/null 2>&1; then
    echo "$GOOGLE_SERVICE_JSON_BASE64" | pbcopy
    echo "   ✅ Copied to clipboard!"
    read -p "   Press Enter after pasting to GitHub..."
fi
echo ""

echo "2. FIREBASE_OPTIONS"
echo "   Length: ${#FIREBASE_OPTIONS_BASE64} chars"
if command -v pbcopy >/dev/null 2>&1; then
    echo "$FIREBASE_OPTIONS_BASE64" | pbcopy
    echo "   ✅ Copied to clipboard!"
    read -p "   Press Enter after pasting to GitHub..."
fi
echo ""

echo "3. GOOGLE_SERVICE_PLIST"
echo "   Length: ${#GOOGLE_SERVICE_PLIST_BASE64} chars"
if command -v pbcopy >/dev/null 2>&1; then
    echo "$GOOGLE_SERVICE_PLIST_BASE64" | pbcopy
    echo "   ✅ Copied to clipboard!"
    read -p "   Press Enter after pasting to GitHub..."
fi
echo ""

echo "✅ All secrets generated successfully!"
echo ""
echo "⚠️  Important reminders:"
echo "   - Paste the ENTIRE string when adding to GitHub secrets"
echo "   - Don't add quotes or extra spaces"
echo "   - The secret should be one continuous line"
echo ""
