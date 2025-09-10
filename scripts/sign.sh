#!/usr/bin/env bash

set -euxo pipefail

# config
KEYCHAIN_NAME="simkick-build"
KEYCHAIN_PATH="$HOME/Library/Keychains/${KEYCHAIN_NAME}.keychain-db"
TEAM_ID="CAG2W9M777"

cleanup() {
    if [ -f "$KEYCHAIN_PATH" ]; then
        echo "Cleaning up keychain..."
        security delete-keychain "$KEYCHAIN_PATH" 2>/dev/null || true
    fi
}

trap cleanup EXIT

echo "Creating temporary keychain..."
security create-keychain -p "temp-password" "$KEYCHAIN_PATH"
security set-keychain-settings -lut 21600 "$KEYCHAIN_PATH"
security list-keychains -d user -s "$KEYCHAIN_PATH" $(security list-keychains -d user | sed s/\"//g)

if [ -n "${DEVELOPER_ID_CERTIFICATE_BASE64:-}" ] && [ -n "${DEVELOPER_ID_CERTIFICATE_PASSWORD:-}" ]; then
    echo "Importing Developer ID certificate..."
    echo "$DEVELOPER_ID_CERTIFICATE_BASE64" | base64 --decode > /tmp/cert.p12
    security import /tmp/cert.p12 -k "$KEYCHAIN_PATH" -P "$DEVELOPER_ID_CERTIFICATE_PASSWORD" -A
    rm /tmp/cert.p12
    security set-key-partition-list -S apple-tool:,apple: -s -k "temp-password" "$KEYCHAIN_PATH"
fi

SIGNING_IDENTITY=$(security find-identity -v -p codesigning "$KEYCHAIN_PATH" | grep -E "(Developer ID Application|Apple Development)" | head -1 | grep -o '"[^"]*"' | sed 's/"//g')

if [ -z "$SIGNING_IDENTITY" ]; then
    echo "Warning: No Developer ID Application certificate found"
    echo "Available identities in keychain:"
    security find-identity -v -p codesigning "$KEYCHAIN_PATH" || true
    exit 1
fi

echo "Using signing identity: $SIGNING_IDENTITY"
echo "Setup complete. Use justfile with these environment variables:"
echo "export CODE_SIGN_IDENTITY=\"$SIGNING_IDENTITY\""
echo "export DEVELOPMENT_TEAM=\"$TEAM_ID\""
echo "export OTHER_CODE_SIGN_FLAGS=\"--keychain=\\\"$KEYCHAIN_PATH\\\"\""
