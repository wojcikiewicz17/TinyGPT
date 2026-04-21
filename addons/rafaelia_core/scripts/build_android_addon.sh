#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${ANDROID_NDK_HOME:-}" ]]; then
  echo "[ERRO] ANDROID_NDK_HOME não definido." >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
OUT_DIR="${ROOT_DIR}/build-android-rafaelia"
TOOLCHAIN="${ANDROID_NDK_HOME}/build/cmake/android.toolchain.cmake"
API_LEVEL="${ANDROID_API_LEVEL:-24}"

ABIS=("armeabi-v7a" "arm64-v8a")

rm -rf "${OUT_DIR}"
mkdir -p "${OUT_DIR}/artifacts"

for ABI in "${ABIS[@]}"; do
  BUILD_DIR="${OUT_DIR}/${ABI}"
  cmake -S "${ROOT_DIR}" -B "${BUILD_DIR}" \
    -DCMAKE_TOOLCHAIN_FILE="${TOOLCHAIN}" \
    -DANDROID_ABI="${ABI}" \
    -DANDROID_PLATFORM="android-${API_LEVEL}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DTINYGPT_BUILD_DEMO=OFF \
    -DTINYGPT_BUILD_TEST=OFF \
    -DTINYGPT_BUILD_PYBINDING=OFF \
    -DTINYGPT_BUILD_RAFAELIA_ADDON=ON \
    -DTINYGPT_USE_CUDA=OFF \
    -DTINYGPT_USE_NCCL=OFF

  cmake --build "${BUILD_DIR}" --config Release --target RafaelIA_core --parallel

  cp "${BUILD_DIR}/addons/rafaelia_core/librafaelia_core.a" "${OUT_DIR}/artifacts/librafaelia_core-${ABI}.a"
done

echo "[OK] artefatos em ${OUT_DIR}/artifacts"
