"""Blur the darkened texture.  Adjust BLUR_RADIUS to tune this stage."""

from pathlib import Path

from PIL import Image, ImageFilter


ROOT = Path(__file__).resolve().parents[2]
INPUT = ROOT / "Art" / "Generated" / "GearTexture" / "03_darkened.png"
OUTPUT = ROOT / "Art" / "Generated" / "GearTexture" / "04_blurred.png"
BLUR_RADIUS = 4.0


def main() -> None:
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    image = Image.open(INPUT).convert("RGB")
    image.filter(ImageFilter.GaussianBlur(BLUR_RADIUS)).save(OUTPUT)
    print(f"Saved {OUTPUT} (Gaussian blur radius {BLUR_RADIUS}).")


if __name__ == "__main__":
    main()
