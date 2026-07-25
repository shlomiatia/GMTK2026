"""Blur the darkened texture, optionally setting the radius from the command line."""

import argparse
from pathlib import Path

from PIL import Image, ImageFilter


ROOT = Path(__file__).resolve().parents[2]
INPUT = ROOT / "Art" / "Generated" / "GearTexture" / "03_darkened.png"
OUTPUT = ROOT / "Art" / "Generated" / "GearTexture" / "04_blurred.png"
BLUR_RADIUS = 6.5  # Default; override with --radius.


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Apply Gaussian blur to the darkened gear texture.")
    parser.add_argument(
        "--radius",
        type=float,
        default=BLUR_RADIUS,
        help="Gaussian blur radius in pixels (default: %(default)s).",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if args.radius < 0:
        raise ValueError("--radius must be zero or greater.")
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    image = Image.open(INPUT).convert("RGB")
    image.filter(ImageFilter.GaussianBlur(args.radius)).save(OUTPUT)
    print(f"Saved {OUTPUT} (Gaussian blur radius {args.radius}).")


if __name__ == "__main__":
    main()
