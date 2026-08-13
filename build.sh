#!/bin/bash
set -e

APP_NAME="NoiosoAI"
BUNDLE_ID="com.noioso.noiosoai.ios"
VERSION="1.0"

echo "Cleaning previous builds..."
rm -rf Payload NoiosoAI-unsigned.ipa .build

echo "Building via xcodebuild for iOS..."
# xcodebuild natively handles Swift Packages and respects the iOS SDK
xcodebuild -scheme $APP_NAME \
           -destination "generic/platform=iOS" \
           -configuration Release \
           CONFIGURATION_BUILD_DIR="$(pwd)/.build/ios"

echo "Creating standard iOS app bundle structure..."
mkdir -p Payload/$APP_NAME.app

# Copy the binary from xcodebuild's output directory
cp .build/ios/$APP_NAME Payload/$APP_NAME.app/$APP_NAME

# Ensure the binary has executable permissions
chmod +x Payload/$APP_NAME.app/$APP_NAME

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
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleVersion</key>
    <string>$VERSION</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>MinimumOSVersion</key>
    <string>15.0</string>
    <key>UIDeviceFamily</key>
    <array>
        <integer>1</integer>
        <integer>2</integer>
    </array>
    <key>UILaunchScreen</key>
    <dict/>
</dict>
</plist>
EOF

echo "Zipping into .ipa..."
zip -r NoiosoAI-unsigned.ipa Payload
echo "Build complete: NoiosoAI-unsigned.ipa created successfully!"