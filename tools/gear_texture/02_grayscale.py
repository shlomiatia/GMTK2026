"""Convert the packed gear texture to grayscale without changing its dimensions."""

from pathlib import Path

from PIL import Image, ImageOps


ROOT = Path(__file__).resolve().parents[2]
INPUT = ROOT / "Art" / "Generated" / "GearTexture" / "01_packed.png"
OUTPUT = ROOT / "Art" / "Generated" / "GearTexture" / "02_grayscale.png"


def main() -> None:
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    image = Image.open(INPUT).convert("RGB")
    ImageOps.grayscale(image).save(OUTPUT)
    print(f"Saved {OUTPUT}.")


if __name__ == "__main__":
    main()
