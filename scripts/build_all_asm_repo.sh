#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${ROOT_DIR}/build-all-asm"

cmake -S "${ROOT_DIR}" -B "${BUILD_DIR}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DTINYGPT_FORCE_ALL_ASM=ON

cmake --build "${BUILD_DIR}" --config Release --parallel

echo "[all-asm] artifacts"
find "${BUILD_DIR}" -maxdepth 3 -type f \( -name 'libtinygpt_all_asm.a' -o -name 'librafaelia_core.a' \)
