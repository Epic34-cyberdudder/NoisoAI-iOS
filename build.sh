#!/bin/bash
set -e

APP_NAME="NoiosoAI"
BUNDLE_ID="com.noioso.noiosoai.ios"
VERSION="1.0"

echo "Cleaning previous builds..."
rm -rf Payload NoiosoAI-unsigned.ipa .build

echo "Building via xcodebuild for iOS..."
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

# Generate Info.plist with missing iOS-specific keys
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
    <key>CFBundleSupportedPlatforms</key>
    <array>
        <string>iPhoneOS</string>
    </array>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>MinimumOSVersion</key>
    <string>15.0</string>
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>arm64</string>
    </array>
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

# Convert the XML Info.plist to Apple's binary format (Crucial for Sideloadly)
plutil -convert binary1 Payload/$APP_NAME.app/Info.plist

# Generate the PkgInfo file (Crucial for iOS validation)
echo -n "APPL????" > Payload/$APP_NAME.app/PkgInfo

echo "Zipping into .ipa..."
zip -r NoiosoAI-unsigned.ipa Payload
echo "Build complete: NoiosoAI-unsigned.ipa created successfully!"