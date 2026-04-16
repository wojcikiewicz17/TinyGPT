#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="${1:-$PWD}"
MODE="${2:-apply}"

if [[ "$MODE" != "apply" && "$MODE" != "print" ]]; then
  echo "usage: $0 [root_dir] [apply|print]" >&2
  exit 1
fi

if [[ "$MODE" == "print" ]]; then
  echo "ROOT_DIR=$ROOT_DIR"
fi

mkdir -p \
  "$ROOT_DIR/nucleus" \
  "$ROOT_DIR/bridge" \
  "$ROOT_DIR/logic" \
  "$ROOT_DIR/governance"

touch \
  "$ROOT_DIR/nucleus/vectra_raw_ring.s" \
  "$ROOT_DIR/nucleus/model_core.c" \
  "$ROOT_DIR/nucleus/topology_7d.h" \
  "$ROOT_DIR/bridge/rafaelia_bridge.py" \
  "$ROOT_DIR/bridge/tensor_quantizer.c" \
  "$ROOT_DIR/bridge/checksum_v4.c" \
  "$ROOT_DIR/logic/config.py" \
  "$ROOT_DIR/logic/dataloader.py" \
  "$ROOT_DIR/logic/train_loop.py" \
  "$ROOT_DIR/governance/ethics_engine.h" \
  "$ROOT_DIR/governance/conformity_nist.cfg" \
  "$ROOT_DIR/governance/kill_switch.c"

cat > "$ROOT_DIR/nucleus/LICENSE" <<'LIC'
PROPRIETARY / RESTRICTIVE (VECTRA-ID)
Uso exclusivo para o Kernel RafaelIA.
LIC

cat > "$ROOT_DIR/bridge/LICENSE" <<'LIC'
MIT OR LGPL
LIC

cat > "$ROOT_DIR/logic/LICENSE" <<'LIC'
GPL-3.0-only
LIC

cat > "$ROOT_DIR/governance/LICENSE" <<'LIC'
ETHICAL-OPEN (RafaelIA-Peace)
Livre para uso humano; proibido para fins bélicos ou predatórios.
LIC

chmod -R u+rwX,go+rX \
  "$ROOT_DIR/nucleus" \
  "$ROOT_DIR/bridge" \
  "$ROOT_DIR/logic" \
  "$ROOT_DIR/governance"

find "$ROOT_DIR/nucleus" "$ROOT_DIR/bridge" "$ROOT_DIR/logic" "$ROOT_DIR/governance" -type f -exec chmod 0644 {} \;
find "$ROOT_DIR/nucleus" "$ROOT_DIR/bridge" "$ROOT_DIR/logic" "$ROOT_DIR/governance" -type d -exec chmod 0755 {} \;

if [[ "$MODE" == "print" ]]; then
  printf '%s\n' \
    "$ROOT_DIR/nucleus" \
    "$ROOT_DIR/bridge" \
    "$ROOT_DIR/logic" \
    "$ROOT_DIR/governance"
fi

echo "Symbiosis setup concluído em: $ROOT_DIR"
