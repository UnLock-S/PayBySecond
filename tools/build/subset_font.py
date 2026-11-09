"""Build deterministic local UI font subsets; full upstream font stays in .local.

python tools/build/subset_font.py --source .local/fonts/NotoSansSC.ttf
Requires env/font-tooling-requirements.txt; ordinary Flutter builds need no Python.
"""
import argparse
import hashlib
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
    for path in (ROOT / "src").rglob("*.dart"):
        if any(part in {".dart_tool", "build"} for part in path.parts):
            continue
        chars.update(ord(c) for c in path.read_text(encoding="utf-8") if ord(c) >= 128)
    return chars


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, required=True)
    args = parser.parse_args()
    if hashlib.sha256(args.source.read_bytes()).hexdigest() != SOURCE_SHA:
        raise SystemExit("Upstream font SHA256 differs; review provenance before updating")
    output = ROOT / "src/apps/pay_by_second/assets/fonts"
    output.mkdir(parents=True, exist_ok=True)
    chars = required_characters()
    for style, weight in [("Regular", 400), ("Bold", 700)]:
        font = TTFont(args.source, recalcTimestamp=False)
        missing = chars - set(font.getBestCmap())
        if missing:
            raise SystemExit(f"Upstream font missing: {sorted(missing)}")
        font = instantiateVariableFont(font, {"wght": weight}, inplace=True)
        for name_id, text in {
            1: "PayBySecond Sans", 2: style, 3: f"PayBySecondSans-{style}",
            4: f"PayBySecond Sans {style}", 6: f"PayBySecondSans-{style}",
            16: "PayBySecond Sans", 17: style,
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
        font.save(output / f"PayBySecondSans-{style}.ttf")
    (output / "coverage.txt").write_text(
        "\n".join(f"{cp:04X}" for cp in sorted(chars)) + "\n", encoding="ascii"
    )
    print(f"Built local Regular/Bold fonts covering {len(chars)} UI codepoints")


if __name__ == "__main__":
    main()
