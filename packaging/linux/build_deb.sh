#!/usr/bin/env bash
set -e

# =====================================================================
# Mingo IDE — Linux .deb & .tar.gz Packaging Script
# =====================================================================

VERSION=${1:-"1.0.0"}
BUNDLE_DIR=${2:-"build/linux/x64/release/bundle"}
OUTPUT_DIR="build/linux/installer"

echo "Building Linux packages for Mingo IDE v${VERSION}..."

if [ ! -d "$BUNDLE_DIR" ]; then
    echo "Error: Bundle directory not found at $BUNDLE_DIR"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

# 1. Package .tar.gz Portable Archive
echo "Creating Portable tar.gz archive..."
tar -czvf "${OUTPUT_DIR}/Mingo-IDE-v${VERSION}-Linux-x64.tar.gz" -C "$BUNDLE_DIR" .

# 2. Assemble Debian package structure
PKG_DIR="build/linux/deb_tree"
rm -rf "$PKG_DIR"
mkdir -p "${PKG_DIR}/DEBIAN"
mkdir -p "${PKG_DIR}/usr/lib/novaide"
mkdir -p "${PKG_DIR}/usr/bin"
mkdir -p "${PKG_DIR}/usr/share/applications"
mkdir -p "${PKG_DIR}/usr/share/pixmaps"

# Copy binary bundle
cp -r "${BUNDLE_DIR}/." "${PKG_DIR}/usr/lib/novaide/"

# Create executable wrapper in /usr/bin
cat << 'EOF' > "${PKG_DIR}/usr/bin/novaide"
#!/usr/bin/env bash
exec /usr/lib/novaide/novaide "$@"
EOF
chmod +x "${PKG_DIR}/usr/bin/novaide"

# Copy desktop launcher
cp packaging/linux/novaide.desktop "${PKG_DIR}/usr/share/applications/"

# Copy icon
if [ -f "packaging/linux/novaide.png" ]; then
    cp packaging/linux/novaide.png "${PKG_DIR}/usr/share/pixmaps/novaide.png"
fi

# Create Debian control file
cat << EOF > "${PKG_DIR}/DEBIAN/control"
Package: novaide
Version: ${VERSION}
Section: devel
Priority: optional
Architecture: amd64
Maintainer: Mingo IDE Team <developer@mingo.ide>
Depends: libgtk-3-0, liblzma5
Description: Mingo IDE - Cross-Platform Developer Environment
 Fast, modern, intelligent cross-platform developer environment.
 Built with Flutter for seamless productivity.
EOF

# Build .deb package
dpkg-deb --build "${PKG_DIR}" "${OUTPUT_DIR}/Mingo-IDE-v${VERSION}-Linux-x64.deb"

echo "Linux packaging complete:"
ls -lh "$OUTPUT_DIR"
