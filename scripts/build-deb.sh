#!/usr/bin/env bash

# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2024-2025 <Nitrux Latinoamericana S.C. <hello@nxos.org>>


# -- Exit on errors.

set -e


# -- Download Source.

SRC_DIR="$(mktemp -d)"

git clone --depth 1 --branch "$WAYQT_BRANCH" https://gitlab.com/desktop-frameworks/wayqt.git "$SRC_DIR/wayqt-src"

cd "$SRC_DIR/wayqt-src"


# -- Configure Build.

meson setup .build --prefix=/usr --buildtype=release


# -- Compile Source.

ninja -C .build -k 0 -j "$(nproc)"


# -- Create a temporary DESTDIR.

DESTDIR="$(pwd)/pkg"

rm -rf "$DESTDIR"


# -- Install to DESTDIR.

DESTDIR="$DESTDIR" ninja -C .build install


# -- Create DEBIAN control file.

mkdir -p "$DESTDIR/DEBIAN"

PKGNAME="dfl-wayqt-qt6"
MAINTAINER="uri_herrera@nxos.org"
ARCHITECTURE="$(dpkg --print-architecture)"
DESCRIPTION="A Qt-based wrapper for various wayland protocols. A Qt-based library to handle Wayland and Wlroots protocols to be used with any Qt project."

cat > "$DESTDIR/DEBIAN/control" <<EOF
Package: $PKGNAME
Version: $PACKAGE_VERSION
Section: utils
Priority: optional
Architecture: $ARCHITECTURE
Maintainer: $MAINTAINER
Description: $DESCRIPTION
EOF


# -- Build the Debian package.

cd "$(dirname "$DESTDIR")"

dpkg-deb --build "$(basename "$DESTDIR")" "${PKGNAME}_${PACKAGE_VERSION}_${ARCHITECTURE}.deb"


# -- Move .deb to ./build/ for CI consistency.

mkdir -p "$GITHUB_WORKSPACE/build"

mv "${PKGNAME}_${PACKAGE_VERSION}_${ARCHITECTURE}.deb" "$GITHUB_WORKSPACE/build/"

echo "Debian package created: $(pwd)/build/${PKGNAME}_${PACKAGE_VERSION}_${ARCHITECTURE}.deb"
