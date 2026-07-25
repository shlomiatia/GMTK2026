"""Create a 1920x1080 white gear texture with non-overlapping circular gears."""

from __future__ import annotations

import math
import random
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[2]
ASSETS = ROOT / "Art" / "Assets" / "Play Scene" / "Enemies"
OUTPUT = ROOT / "Art" / "Generated" / "GearTexture" / "01_packed.png"
WIDTH, HEIGHT = 1920, 1080

# The requested collision radii: half the smallest dimension of each source image.
GEARS = {
    "large": (ASSETS / "Gear_Large.png", 113.0),
    "medium": (ASSETS / "Gear_Medium.png", 77.0),
    "small": (ASSETS / "Gear_Small.png", 40.5),
}


RANDOM_SEED = 20260725


def allowed_overlap(name_a: str, name_b: str) -> float:
    """Let every gear size interlock slightly for a more natural random pile."""
    if name_a == name_b == "small":
        return 7.0
    if "large" in (name_a, name_b):
        return 16.0
    return 12.0


def intersects(a: tuple[str, float, float, float], b: tuple[str, float, float, float]) -> bool:
    return math.hypot(a[1] - b[1], a[2] - b[2]) < a[3] + b[3] - allowed_overlap(a[0], b[0])


def paste_centered(canvas: Image.Image, sprite: Image.Image, x: float, y: float) -> None:
    position = (round(x - sprite.width / 2), round(y - sprite.height / 2))
    canvas.alpha_composite(sprite, position)


def random_candidate(name: str, rng: random.Random) -> tuple[str, float, float, float]:
    radius = GEARS[name][1]
    return (name, rng.uniform(radius, WIDTH - radius), rng.uniform(radius, HEIGHT - radius), radius)


def random_border_candidate(name: str, side: str, rng: random.Random) -> tuple[str, float, float, float]:
    """Place a circle with 30–70% of its radius beyond a chosen canvas edge."""
    radius = GEARS[name][1]
    outside = rng.uniform(0.30, 0.70) * radius
    if side == "left":
        return (name, -outside, rng.uniform(-radius, HEIGHT + radius), radius)
    if side == "right":
        return (name, WIDTH + outside, rng.uniform(-radius, HEIGHT + radius), radius)
    if side == "top":
        return (name, rng.uniform(-radius, WIDTH + radius), -outside, radius)
    return (name, rng.uniform(-radius, WIDTH + radius), HEIGHT + outside, radius)


def main() -> None:
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    sprites = {name: Image.open(path).convert("RGBA") for name, (path, _) in GEARS.items()}
    rng = random.Random(RANDOM_SEED)
    placed: list[tuple[str, float, float, float]] = []

    # Random sequential packing intentionally avoids a visible grid. First add
    # cropped edge gears, then fill the centre from large through small sizes.
    edge_sides = ["left", "right", "top", "bottom"] * 3
    edge_names = ["large", "medium", "small", "medium"] * 3
    rng.shuffle(edge_sides)
    for name, side in zip(edge_names, edge_sides):
        for _attempt in range(50_000):
            candidate = random_border_candidate(name, side, rng)
            if not any(intersects(candidate, other) for other in placed):
                placed.append(candidate)
                break
        else:
            raise RuntimeError(f"Could not fit an edge {name} gear.")

    for name, count in (("large", 5), ("medium", 18)):
        for _ in range(count):
            for _attempt in range(50_000):
                candidate = random_candidate(name, rng)
                if not any(intersects(candidate, other) for other in placed):
                    placed.append(candidate)
                    break
            else:
                raise RuntimeError(f"Could not fit all requested {name} gears.")

    small_radius = GEARS["small"][1]
    consecutive_misses = 0
    while consecutive_misses < 30_000:
        candidate = (
            "small",
            rng.uniform(-small_radius * 0.2, WIDTH + small_radius * 0.2),
            rng.uniform(-small_radius * 0.2, HEIGHT + small_radius * 0.2),
            small_radius,
        )
        if any(intersects(candidate, other) for other in placed):
            consecutive_misses += 1
            continue
        placed.append(candidate)
        consecutive_misses = 0

    # Guard against accidental changes to the layout constants introducing excess overlap.
    for index, circle in enumerate(placed):
        if any(intersects(circle, other) for other in placed[index + 1 :]):
            raise RuntimeError("Gear layout exceeds its configured overlap tolerance.")

    canvas = Image.new("RGBA", (WIDTH, HEIGHT), "white")
    for name, x, y, _ in placed:
        sprite = sprites[name].rotate(rng.randrange(360), resample=Image.Resampling.BICUBIC, expand=True)
        paste_centered(canvas, sprite, x, y)
    canvas.convert("RGB").save(OUTPUT)
    print(f"Saved {OUTPUT} ({len(placed)} gears).")


if __name__ == "__main__":
    main()
