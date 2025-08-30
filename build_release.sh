#!/bin/bash
# ========================================
# TubeTok Downloader - GitHub Release Builder
# ========================================

set -e

echo "Building TubeTok Downloader releases for all platforms..."
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're on the right platform
case "$(uname -s)" in
    Linux*)     PLATFORM=linux;;
    Darwin*)    PLATFORM=macos;;
    CYGWIN*|MINGW*|MSYS*) PLATFORM=windows;;
    *)          PLATFORM=unknown;;
esac

print_status "Detected platform: $PLATFORM"

# Create releases directory
RELEASE_DIR="releases"
if [ -d "$RELEASE_DIR" ]; then
    print_warning "Removing existing releases directory..."
    rm -rf "$RELEASE_DIR"
fi
mkdir -p "$RELEASE_DIR"

# Build for current platform
print_status "Building for $PLATFORM..."
case $PLATFORM in
    windows)
        if [ -f "build.bat" ]; then
            print_status "Running Windows build..."
            cmd //c build.bat
            if [ -f "dist/TubeTokDownloader.exe" ]; then
                cp "dist/TubeTokDownloader.exe" "$RELEASE_DIR/TubeTokDownloader-Windows.exe"
                print_status "Windows executable created: TubeTokDownloader-Windows.exe"
            fi
        else
            print_error "build.bat not found!"
        fi
        ;;
    linux)
        if [ -f "build_linux.sh" ]; then
            print_status "Running Linux build..."
            chmod +x build_linux.sh
            ./build_linux.sh
            if [ -f "dist/TubeTokDownloader.AppImage" ]; then
                cp "dist/TubeTokDownloader.AppImage" "$RELEASE_DIR/TubeTokDownloader-Linux.AppImage"
                print_status "Linux AppImage created: TubeTokDownloader-Linux.AppImage"
            elif [ -f "dist/TubeTokDownloader" ]; then
                cp "dist/TubeTokDownloader" "$RELEASE_DIR/TubeTokDownloader-Linux"
                print_status "Linux executable created: TubeTokDownloader-Linux"
            fi
        else
            print_error "build_linux.sh not found!"
        fi
        ;;
    macos)
        if [ -f "build_macos.sh" ]; then
            print_status "Running macOS build..."
            chmod +x build_macos.sh
            ./build_macos.sh
            if [ -f "dist/TubeTok Downloader.dmg" ]; then
                cp "dist/TubeTok Downloader.dmg" "$RELEASE_DIR/TubeTokDownloader-macOS.dmg"
                print_status "macOS DMG created: TubeTokDownloader-macOS.dmg"
            elif [ -d "dist/TubeTok Downloader.app" ]; then
                print_status "macOS app bundle created (DMG not available)"
            fi
        else
            print_error "build_macos.sh not found!"
        fi
        ;;
    *)
        print_error "Unsupported platform: $PLATFORM"
        exit 1
        ;;
esac

# Copy additional files to release
print_status "Preparing release files..."

# Copy README and other docs
if [ -f "README.md" ]; then
    cp "README.md" "$RELEASE_DIR/"
fi
if [ -f "README.ru.md" ]; then
    cp "README.ru.md" "$RELEASE_DIR/"
fi
if [ -f "LICENSE" ]; then
    cp "LICENSE" "$RELEASE_DIR/"
fi

# Create checksums
print_status "Creating checksums..."
cd "$RELEASE_DIR"
for file in *; do
    if [ -f "$file" ] && [[ "$file" != *.md ]] && [[ "$file" != LICENSE ]]; then
        sha256sum "$file" > "${file}.sha256"
        print_status "Checksum created for $file"
    fi
done
cd ..

# Create release info
VERSION=$(grep -oP 'VERSION = "\K[^"]*' core/version.py 2>/dev/null || echo "1.0.0")
RELEASE_NOTES="$RELEASE_DIR/RELEASE_NOTES.md"
cat > "$RELEASE_NOTES" << EOF
# TubeTok Downloader v$VERSION

## What's New
- [Add release notes here]

## Downloads
EOF

# Add download links to release notes
for file in "$RELEASE_DIR"/*; do
    if [ -f "$file" ] && [[ "$file" != *.md ]] && [[ "$file" != LICENSE ]]; then
        filename=$(basename "$file")
        echo "- [$filename](https://github.com/erfukuby/toktube/releases/download/v$VERSION/$filename)" >> "$RELEASE_NOTES"
    fi
done

echo "" >> "$RELEASE_NOTES"
echo "## Installation Instructions" >> "$RELEASE_NOTES"
echo "### Windows" >> "$RELEASE_NOTES"
echo "1. Download \`TubeTokDownloader-Windows.exe\`" >> "$RELEASE_NOTES"
echo "2. Run the installer" >> "$RELEASE_NOTES"
echo "3. Launch TubeTok Downloader" >> "$RELEASE_NOTES"
echo "" >> "$RELEASE_NOTES"
echo "### Linux" >> "$RELEASE_NOTES"
echo "1. Download \`TubeTokDownloader-Linux.AppImage\` or \`TubeTokDownloader-Linux\`" >> "$RELEASE_NOTES"
echo "2. Make executable: \`chmod +x TubeTokDownloader-Linux*\`" >> "$RELEASE_NOTES"
echo "3. Run: \`./TubeTokDownloader-Linux*\`" >> "$RELEASE_NOTES"
echo "4. Install FFmpeg: \`sudo apt install ffmpeg\` (Ubuntu/Debian)" >> "$RELEASE_NOTES"
echo "" >> "$RELEASE_NOTES"
echo "### macOS" >> "$RELEASE_NOTES"
echo "1. Download \`TubeTokDownloader-macOS.dmg\`" >> "$RELEASE_NOTES"
echo "2. Mount the DMG and drag to Applications" >> "$RELEASE_NOTES"
echo "3. Install FFmpeg: \`brew install ffmpeg\`" >> "$RELEASE_NOTES"

print_status "Release files prepared in: $RELEASE_DIR/"
print_status "Files:"
ls -la "$RELEASE_DIR/"

print_status "Next steps:"
echo "1. Test the built executables"
echo "2. Update version in core/version.py if needed"
echo "3. Create GitHub release:"
echo "   - Go to https://github.com/erfukuby/toktube/releases"
echo "   - Click 'Create a new release'"
echo "   - Tag: v$VERSION"
echo "   - Title: TubeTok Downloader v$VERSION"
echo "   - Copy content from $RELEASE_NOTES"
echo "   - Upload all files from $RELEASE_DIR/"
echo "   - Publish release"

print_status "Release preparation complete!"
