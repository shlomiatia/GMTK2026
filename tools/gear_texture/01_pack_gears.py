"""Create a 1920x1080 white gear texture with non-overlapping circular gears."""

from __future__ import annotations

import math
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


def closest_point(points: list[tuple[float, float]], target: tuple[float, float]) -> tuple[float, float]:
    return min(points, key=lambda point: (point[0] - target[0]) ** 2 + (point[1] - target[1]) ** 2)


def intersects(a: tuple[float, float, float], b: tuple[float, float, float]) -> bool:
    # Tangent circles are allowed; the small tolerance avoids floating-point noise
    # classifying a mathematically tangent pair as intersecting.
    return math.hypot(a[0] - b[0], a[1] - b[1]) < a[2] + b[2] - 0.01


def paste_centered(canvas: Image.Image, sprite: Image.Image, x: float, y: float) -> None:
    position = (round(x - sprite.width / 2), round(y - sprite.height / 2))
    canvas.alpha_composite(sprite, position)


def main() -> None:
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    sprites = {name: Image.open(path).convert("RGBA") for name, (path, _) in GEARS.items()}

    # A hexagonal small-gear grid is the densest regular arrangement for the smallest
    # gear.  Larger gears replace nearby small gears at selected, well-spaced centers.
    small_radius = GEARS["small"][1]
    row_gap = math.sqrt(3) * small_radius
    small_centers: list[tuple[float, float]] = []
    row = 0
    y = small_radius
    while y <= HEIGHT - small_radius:
        x = small_radius if row % 2 == 0 else 2 * small_radius
        while x <= WIDTH - small_radius:
            small_centers.append((x, y))
            x += 2 * small_radius
        row += 1
        y += row_gap

    placed: list[tuple[str, float, float, float]] = []
    # These targets deliberately distribute all three supplied sizes over the texture.
    requested = [
        ("large", (405, 310)),
        ("large", (1110, 380)),
        ("large", (1630, 820)),
        ("medium", (800, 145)),
        ("medium", (1450, 170)),
        ("medium", (305, 790)),
        ("medium", (800, 790)),
        ("medium", (1250, 730)),
        ("medium", (1660, 515)),
    ]

    for name, target in requested:
        radius = GEARS[name][1]
        center = closest_point(small_centers, target)
        candidate = (center[0], center[1], radius)
        if any(intersects(candidate, (x, y, other_radius)) for _, x, y, other_radius in placed):
            raise RuntimeError(f"The configured {name} gear at {center} overlaps another large gear.")
        placed.append((name, *candidate))
        small_centers = [
            point
            for point in small_centers
            if math.hypot(point[0] - center[0], point[1] - center[1]) >= radius + small_radius
        ]

    placed.extend(("small", x, y, small_radius) for x, y in small_centers)

    # Guard against accidental changes to the layout constants introducing an overlap.
    circles = [(x, y, radius) for _, x, y, radius in placed]
    for index, circle in enumerate(circles):
        if any(intersects(circle, other) for other in circles[index + 1 :]):
            raise RuntimeError("Gear layout contains an overlap.")

    canvas = Image.new("RGBA", (WIDTH, HEIGHT), "white")
    for name, x, y, _ in placed:
        paste_centered(canvas, sprites[name], x, y)
    canvas.convert("RGB").save(OUTPUT)
    print(f"Saved {OUTPUT} ({len(placed)} gears).")


if __name__ == "__main__":
    main()
