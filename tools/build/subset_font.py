"""Build deterministic local UI font subsets; full upstream font stays in .local.

python tools/build/subset_font.py --source .local/fonts/NotoSansSC.ttf --source-jp .local/fonts/NotoSansJP.ttf
Requires env/font-tooling-requirements.txt; ordinary Flutter builds need no Python.
"""
import argparse
import hashlib
import json
from pathlib import Path

from fontTools import subset
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont

ROOT = Path(__file__).resolve().parents[2]
SOURCE_SHA = "a3041811a78c361b1de50f953c805e0244951c21c5bd412f7232ef0d899af0da"


def required_characters():
    chars = set(range(32, 127)) | {0xA0, 0xA5}
    seed = ROOT / "config/app/font-extra-characters.txt"
    chars.update(ord(c) for c in seed.read_text(encoding="utf-8") if ord(c) >= 128)
    for path in (ROOT / "src").rglob("*"):
        if path.suffix not in {".dart", ".arb"}:
            continue
        if any(part in {".dart_tool", "build"} for part in path.parts):
            continue
        chars.update(ord(c) for c in path.read_text(encoding="utf-8") if ord(c) >= 128)
    return chars


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--source-jp", type=Path, required=True)
    args = parser.parse_args()
    output = ROOT / "src/apps/pay_by_second/assets/fonts"
    output.mkdir(parents=True, exist_ok=True)
    chars = required_characters()
    sc_available = set(TTFont(args.source, recalcTimestamp=False).getBestCmap())
    # Framework-localized controls (for example the license page) also use kana.
    chars.update(cp for cp in sc_available if 0x3040 <= cp <= 0x30FF)
    chars.update({0xA9, 0xAE})
    build_font(args.source, SOURCE_SHA, chars, output, "PayBySecondSans", "PayBySecond Sans")
    jp_source = TTFont(args.source_jp, recalcTimestamp=False)
    jp_available = set(jp_source.getBestCmap())
    jp_messages = json.loads((ROOT / "src/apps/pay_by_second/lib/l10n/app_ja.arb").read_text(encoding="utf-8"))
    jp_required = {ord(c) for key, value in jp_messages.items() if not key.startswith("@") for c in value if ord(c) >= 32}
    if jp_required - jp_available:
        raise SystemExit(f"Japanese translations lack native JP glyphs: {sorted(jp_required - jp_available)}")
    build_font(args.source_jp, "c2f3b4d463500a2ddcd3849cded1fceeb9fd6d1c32e6cbecd568453ba50fc68f", chars & jp_available, output, "PayBySecondSansJP", "PayBySecond Sans JP")
    (output / "coverage.txt").write_text(
        "\n".join(f"{cp:04X}" for cp in sorted(chars)) + "\n", encoding="ascii"
    )
    print(f"Built local SC/JP Regular/Bold fonts covering {len(chars)} UI codepoints")


def build_font(source, expected_sha, chars, output, prefix, family):
    if hashlib.sha256(source.read_bytes()).hexdigest() != expected_sha:
        raise SystemExit("Upstream font SHA256 differs; review provenance before updating")
    for style, weight in [("Regular", 400), ("Bold", 700)]:
        font = TTFont(source, recalcTimestamp=False)
        missing = chars - set(font.getBestCmap())
        if missing:
            raise SystemExit(f"Upstream font missing: {sorted(missing)}")
        font = instantiateVariableFont(font, {"wght": weight}, inplace=True)
        for name_id, text in {
            1: family, 2: style, 3: f"{prefix}-{style}",
            4: f"{family} {style}", 6: f"{prefix}-{style}",
            16: family, 17: style,
        }.items():
            for record in font["name"].names:
                if record.nameID == name_id:
                    record.string = text.encode(record.getEncoding())
        options = subset.Options()
        options.recalc_timestamp = False
        options.name_IDs = ["*"]
        subsetter = subset.Subsetter(options=options)
        subsetter.populate(unicodes=chars)
        subsetter.subset(font)
        font.save(output / f"{prefix}-{style}.ttf")


if __name__ == "__main__":
    main()
