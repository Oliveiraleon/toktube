#!/bin/bash
# ========================================
# TubeTok Downloader Build Script - Linux AppImage
# ========================================

set -e  # Exit on any error

echo "Building TubeTok Downloader for Linux..."
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

# Create single executable
echo "Creating Linux executable..."
python -m PyInstaller \
    --onefile \
    --windowed \
    --name="TubeTokDownloader" \
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
    main.py

# Check if AppImage tools are available
if command -v appimagetool >/dev/null 2>&1; then
    echo "Creating AppImage..."
    
    # Create AppDir structure
    mkdir -p dist/TubeTokDownloader.AppDir/usr/bin
    mkdir -p dist/TubeTokDownloader.AppDir/usr/share/applications
    mkdir -p dist/TubeTokDownloader.AppDir/usr/share/icons/hicolor/256x256/apps
    
    # Copy executable
    cp dist/TubeTokDownloader dist/TubeTokDownloader.AppDir/usr/bin/
    
    # Create desktop file
    cat > dist/TubeTokDownloader.AppDir/TubeTokDownloader.desktop << EOF
[Desktop Entry]
Type=Application
Name=TubeTok Downloader
Comment=Modern video and audio downloader
Exec=TubeTokDownloader
Icon=TubeTokDownloader
Categories=AudioVideo;Network;
EOF
    
    # Copy icon (convert from ico to png if needed)
    if command -v convert >/dev/null 2>&1; then
        convert assets/app.ico dist/TubeTokDownloader.AppDir/TubeTokDownloader.png
    else
        cp assets/app.png dist/TubeTokDownloader.AppDir/TubeTokDownloader.png 2>/dev/null || \
        cp assets/app.ico dist/TubeTokDownloader.AppDir/TubeTokDownloader.png
    fi
    
    # Copy desktop file to proper location
    cp dist/TubeTokDownloader.AppDir/TubeTokDownloader.desktop dist/TubeTokDownloader.AppDir/usr/share/applications/
    
    # Copy icon to proper location
    cp dist/TubeTokDownloader.AppDir/TubeTokDownloader.png dist/TubeTokDownloader.AppDir/usr/share/icons/hicolor/256x256/apps/
    
    # Create AppRun
    cat > dist/TubeTokDownloader.AppDir/AppRun << 'EOF'
#!/bin/bash
SELF=$(readlink -f "$0")
HERE=${SELF%/*}
export PATH="${HERE}/usr/bin/:${PATH}"
export LD_LIBRARY_PATH="${HERE}/usr/lib/:${LD_LIBRARY_PATH}"
exec "${HERE}/usr/bin/TubeTokDownloader" "$@"
EOF
    chmod +x dist/TubeTokDownloader.AppDir/AppRun
    
    # Create AppImage
    cd dist
    appimagetool TubeTokDownloader.AppDir TubeTokDownloader.AppImage
    cd ..
    
    echo
    echo "========================================"
    echo "AppImage created successfully!"
    echo "Location: dist/TubeTokDownloader.AppImage"
    echo "Size: $(du -h dist/TubeTokDownloader.AppImage | cut -f1)"
    echo "========================================"
else
    echo
    echo "========================================"
    echo "Build completed successfully!"
    echo "Location: dist/TubeTokDownloader"
    echo "Size: $(du -h dist/TubeTokDownloader | cut -f1)"
    echo
    echo "Note: Install appimagetool to create AppImage:"
    echo "sudo apt install appimagetool  # Ubuntu/Debian"
    echo "========================================"
fi

echo
echo "To run: ./dist/TubeTokDownloader"
echo "Make sure FFmpeg is installed: sudo apt install ffmpeg"
