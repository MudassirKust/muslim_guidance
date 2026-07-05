#!/bin/bash

echo "🚀 Building Muslim Guidance App for Release..."

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    exit 1
fi

# Get current version from pubspec.yaml
VERSION=$(grep "version:" pubspec.yaml | sed 's/version: //')
echo "📋 Current version: $VERSION"

# Check Flutter version
echo "📱 Flutter version:"
flutter --version

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Check for any issues
echo "🔍 Checking for potential issues..."
flutter analyze

# Build AAB file with version info
echo "🔨 Building AAB file for version $VERSION..."
flutter build appbundle --release --build-name=1.0.1 --build-number=9

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "📱 AAB file location: build/app/outputs/bundle/release/app-release.aab"
    echo "📏 File size:"
    ls -lh build/app/outputs/bundle/release/app-release.aab
    
    # Optional: Copy to a more accessible location with version
    echo "📋 Copying AAB to project root..."
    cp build/app/outputs/bundle/release/app-release.aab "./muslim-guidance-v${VERSION}.aab"
    echo "✅ AAB copied to: ./muslim-guidance-v${VERSION}.aab"
    
    echo ""
    echo "🎉 Release build completed successfully!"
    echo "📤 You can now upload the AAB file to Google Play Console"
else
    echo "❌ Build failed!"
    echo "🔍 Check the error messages above for details"
    exit 1
fi
