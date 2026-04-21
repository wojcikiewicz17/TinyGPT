#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "generated" / "all_asm"
MANIFEST = OUT_DIR / "manifest.json"
LISTFILE = OUT_DIR / "sources.cmake"

EXTS = {".c", ".cc", ".cpp", ".cxx", ".py"}
SKIP_DIRS = {
    ".git", "build", "build-asm-only", "build-android-rafaelia", "build-all-asm",
    "generated", "third_party", "test/googletest", "src/TinyTorch", "addons/rafaelia_core/asm",
}


def should_skip(path: Path) -> bool:
    s = path.as_posix()
    return any(s == d or s.startswith(f"{d}/") for d in SKIP_DIRS)


def sanitize_symbol(rel: str) -> str:
    cleaned = rel.replace("/", "_").replace(".", "_").replace("-", "_")
    digest = hashlib.sha1(rel.encode("utf-8")).hexdigest()[:12]
    return f"asm_unit_{cleaned}_{digest}"


def asm_for(symbol: str, rel: str) -> str:
    return f""".text
#if defined(__x86_64__)
.global {symbol}
.type {symbol}, %function
{symbol}:
    /* generated from: {rel} */
    xor %eax, %eax
    ret
#elif defined(__aarch64__)
.global {symbol}
.type {symbol}, %function
{symbol}:
    /* generated from: {rel} */
    mov w0, #0
    ret
#else
.global {symbol}
.type {symbol}, %function
{symbol}:
    /* generated from: {rel} */
    .byte 0
#endif
"""


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    generated = []
    units = []

    for p in sorted(ROOT.rglob("*")):
        if not p.is_file():
            continue
        rel = p.relative_to(ROOT)
        if should_skip(rel.parent):
            continue
        if p.suffix not in EXTS:
            continue

        rel_posix = rel.as_posix()
        symbol = sanitize_symbol(rel_posix)
        out_file = OUT_DIR / (rel_posix.replace("/", "__") + ".S")
        out_file.parent.mkdir(parents=True, exist_ok=True)
        out_file.write_text(asm_for(symbol, rel_posix), encoding="utf-8")
        generated.append(out_file)
        units.append({"source": rel_posix, "asm": out_file.relative_to(ROOT).as_posix(), "symbol": symbol})

    MANIFEST.write_text(json.dumps({"count": len(units), "units": units}, indent=2), encoding="utf-8")

    with LISTFILE.open("w", encoding="utf-8") as f:
        f.write("set(TINYGPT_ALL_ASM_SOURCES\n")
        for g in generated:
            f.write(f"  \"{g.as_posix()}\"\n")
        f.write(")\n")

    print(f"generated {len(units)} asm units")


if __name__ == "__main__":
    main()
