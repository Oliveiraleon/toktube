#!/bin/bash
# ========================================
# TubeTok Downloader Build Script - macOS
# ========================================

set -e  # Exit on any error

echo "Building TubeTok Downloader for macOS..."
echo

# Check if virtual environment exists
if [ ! -d ".venv" ]; then
    echo "ERROR: Virtual environment not found!"
    echo "Please run: python3 -m venv .venv"
    echo "Then install dependencies: .venv/bin/pip install -r requirements.txt"
    exit 1
fi

# Activate virtual environment
source .venv/bin/activate

# Check if PyInstaller is installed
if ! python -m pip show pyinstaller >/dev/null 2>&1; then
    echo "Installing PyInstaller..."
    python -m pip install pyinstaller
fi

# Kill any running processes
pkill -f TubeTokDownloader || true

# Clean previous builds
if [ -d "dist" ]; then
    echo "Cleaning previous dist folder..."
    rm -rf dist
fi
if [ -d "build" ]; then
    echo "Cleaning previous build folder..."
    rm -rf build
fi

# Create macOS app bundle
echo "Creating macOS app bundle..."
python -m PyInstaller \
    --onedir \
    --windowed \
    --name="TubeTok Downloader" \
    --icon="assets/app.ico" \
    --add-data="assets:assets" \
    --add-data="ui/themes:ui/themes" \
    --hidden-import="PySide6.QtCore" \
    --hidden-import="PySide6.QtGui" \
    --hidden-import="PySide6.QtWidgets" \
    --hidden-import="yt_dlp" \
    --hidden-import="PIL" \
    --hidden-import="cryptography" \
    --hidden-import="cryptography.fernet" \
    --collect-all="yt_dlp" \
    --collect-all="PySide6" \
    --collect-submodules="core" \
    --collect-submodules="ui" \
    --distpath="dist" \
    --workpath="build" \
    --osx-bundle-identifier="com.erfukuby.tubetoken" \
    main.py

# Create DMG if create-dmg is available
if command -v create-dmg >/dev/null 2>&1; then
    echo "Creating DMG installer..."
    
    # Create temporary DMG directory
    mkdir -p dist/dmg
    cp -R "dist/TubeTok Downloader.app" dist/dmg/
    
    # Create Applications symlink
    ln -sf /Applications dist/dmg/Applications
    
    # Create DMG
    create-dmg \
        --volname "TubeTok Downloader" \
        --volicon "assets/app.ico" \
        --window-pos 200 120 \
        --window-size 800 400 \
        --icon-size 100 \
        --icon "TubeTok Downloader.app" 200 190 \
        --hide-extension "TubeTok Downloader.app" \
        --app-drop-link 600 185 \
        "dist/TubeTok Downloader.dmg" \
        "dist/dmg/"
    
    # Clean up
    rm -rf dist/dmg
    
    echo
    echo "========================================"
    echo "DMG created successfully!"
    echo "Location: dist/TubeTok Downloader.dmg"
    echo "Size: $(du -h "dist/TubeTok Downloader.dmg" | cut -f1)"
    echo "========================================"
else
    echo
    echo "========================================"
    echo "App bundle created successfully!"
    echo "Location: dist/TubeTok Downloader.app"
    echo "Size: $(du -sh "dist/TubeTok Downloader.app" | cut -f1)"
    echo
    echo "Note: Install create-dmg to create DMG installer:"
    echo "brew install create-dmg"
    echo "========================================"
fi

# Check code signing (optional)
if command -v codesign >/dev/null 2>&1; then
    echo
    echo "Note: For distribution, consider code signing:"
    echo "codesign --force --deep --sign \"Developer ID Application: Your Name\" \"dist/TubeTok Downloader.app\""
    echo
    echo "For notarization (required for Gatekeeper):"
    echo "xcrun notarytool submit \"dist/TubeTok Downloader.dmg\" --keychain-profile \"notarytool-profile\" --wait"
fi

echo
echo "To run: open \"dist/TubeTok Downloader.app\""
echo "Make sure FFmpeg is installed: brew install ffmpeg"
