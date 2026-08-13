#!/bin/bash
set -e

APP_NAME="NoiosoAI"
BUNDLE_ID="com.noioso.noiosoai.ios"
VERSION="1.0"

echo "Building via Swift Package Manager..."
swift build -c release --triple arm64-apple-ios15.0 --sdk $(xcrun --sdk iphoneos --show-sdk-path)

echo "Packaging .ipa structure..."
mkdir -p Payload/$APP_NAME.app

# Move the compiled binary from SPM output directory
cp .build/arm64-apple-ios/release/$APP_NAME Payload/$APP_NAME.app/

# Generate Info.plist
cat <<EOF > Payload/$APP_NAME.app/Info.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>$APP_NAME</string>
    <key>CFBundleVersion</key>
    <string>$VERSION</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>MinimumOSVersion</key>
    <string>15.0</string>
    <key>UILaunchScreen</key>
    <dict/>
</dict>
</plist>
EOF

echo "Zipping to .ipa..."
zip -r NoiosoAI-unsigned.ipa Payload
echo "Build complete: NoiosoAI-unsigned.ipa created!"