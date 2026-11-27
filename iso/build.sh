#!/usr/bin/env bash
# Builds the BredOS ISO. Must run as root inside Debian 13 (trixie).
# On GitHub this is done by .github/workflows/build-iso.yml.
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="/tmp/bredos-build"
OUT_DIR="${SRC_DIR}/out"
STAMP="$(date +%Y%m%d)"

mkdir -p "${OUT_DIR}"
# Always keep the build log, even if the build fails.
trap 'cp -f "${WORK_DIR}/build.log" "${OUT_DIR}/build.log" 2>/dev/null || true' EXIT

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y live-build debootstrap xorriso squashfs-tools mtools dosfstools \
  isolinux syslinux-common grub-pc-bin grub-efi-amd64-bin ca-certificates cpio

rm -rf "${WORK_DIR}"
mkdir -p "${WORK_DIR}"
cd "${WORK_DIR}"

lb config \
  --distribution trixie \
  --architectures amd64 \
  --binary-image iso-hybrid \
  --archive-areas "main contrib non-free-firmware" \
  --debian-installer none \
  --apt-indices false \
  --memtest none \
  --iso-application "BredOS" \
  --iso-publisher "BredOS Project" \
  --iso-volume "BredOS" \
  --bootappend-live "boot=live components quiet username=bread hostname=bredos" \
  --mirror-bootstrap "http://deb.debian.org/debian/" \
  --mirror-chroot "http://deb.debian.org/debian/" \
  --mirror-binary "http://deb.debian.org/debian/"

# Overlay our own configuration on top of the generated one.
cp -a "${SRC_DIR}/iso/config/." config/
chmod +x config/hooks/normal/* config/includes.chroot/usr/local/bin/* 2>/dev/null || true

# Theme assets from the creative side (wallpapers etc).
if ls "${SRC_DIR}"/theme/wallpapers/*.png >/dev/null 2>&1; then
  mkdir -p config/includes.chroot/usr/share/backgrounds/bredos
  cp "${SRC_DIR}"/theme/wallpapers/*.png config/includes.chroot/usr/share/backgrounds/bredos/
fi

lb build 2>&1 | tee build.log

ISO="$(ls -1 ./*.iso | head -n 1)"
FINAL="${OUT_DIR}/BredOS-${STAMP}-amd64.iso"
mv "${ISO}" "${FINAL}"
(cd "${OUT_DIR}" && sha256sum "$(basename "${FINAL}")" > "$(basename "${FINAL}").sha256")
echo "Done: ${FINAL}"
