"""Darken the grayscale texture.  Adjust BRIGHTNESS to tune this stage."""

from pathlib import Path

from PIL import Image, ImageEnhance


ROOT = Path(__file__).resolve().parents[2]
INPUT = ROOT / "Art" / "Generated" / "GearTexture" / "02_grayscale.png"
OUTPUT = ROOT / "Art" / "Generated" / "GearTexture" / "03_darkened.png"
BRIGHTNESS = 0.55  # 1.0 is unchanged; lower values are darker.


def main() -> None:
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    image = Image.open(INPUT).convert("RGB")
    ImageEnhance.Brightness(image).enhance(BRIGHTNESS).save(OUTPUT)
    print(f"Saved {OUTPUT} (brightness {BRIGHTNESS}).")


if __name__ == "__main__":
    main()
