"""Darken the grayscale texture, optionally setting brightness from the command line."""

import argparse
from pathlib import Path

from PIL import Image, ImageEnhance


ROOT = Path(__file__).resolve().parents[2]
INPUT = ROOT / "Art" / "Generated" / "GearTexture" / "02_grayscale.png"
OUTPUT = ROOT / "Art" / "Generated" / "GearTexture" / "03_darkened.png"
BRIGHTNESS = 0.44  # Default; override with --brightness.


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Darken gears while preserving the white background.")
    parser.add_argument(
        "--brightness",
        type=float,
        default=BRIGHTNESS,
        help="Gear brightness: 1.0 is unchanged; lower values are darker (default: %(default)s).",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if args.brightness < 0:
        raise ValueError("--brightness must be zero or greater.")
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    image = Image.open(INPUT).convert("RGB")
    darkened = ImageEnhance.Brightness(image).enhance(args.brightness)
    # Only source pixels that are not pure white are gear pixels. Compositing by this
    # mask keeps the texture's white background completely unchanged at this stage.
    gear_mask = image.convert("L").point(lambda value: 0 if value == 255 else 255)
    Image.composite(darkened, image, gear_mask).save(OUTPUT)
    print(f"Saved {OUTPUT} (gear brightness {args.brightness}; white background preserved).")


if __name__ == "__main__":
    main()
