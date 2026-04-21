#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${ROOT_DIR}/build-asm-only"
BUILD_TYPE="${BUILD_TYPE:-Release}"

SIMD_FLAGS=()
ARCH="$(uname -m)"
OS="$(uname -s)"

case "${ARCH}" in
  aarch64|arm64)
    SIMD_FLAGS+=("-DRAFAELIA_ENABLE_NEON=ON")
    ;;
  x86_64|amd64)
    SIMD_FLAGS+=("-DRAFAELIA_ENABLE_SIMD=ON")
    ;;
  *)
    ;;
esac

cmake -S "${ROOT_DIR}" -B "${BUILD_DIR}" \
  -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
  -DTINYGPT_ASM_ONLY=ON \
  "${SIMD_FLAGS[@]}"

cmake --build "${BUILD_DIR}" --config "${BUILD_TYPE}" --parallel

echo "[asm-only] OS=${OS} ARCH=${ARCH} build_dir=${BUILD_DIR}"
find "${BUILD_DIR}" -maxdepth 3 -type f \( -name 'librafaelia_core.a' -o -name 'rafaelia_core.lib' \)
