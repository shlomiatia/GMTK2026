# Gear texture pipeline

Run these scripts from the repository root, in order:

```powershell
python tools/gear_texture/01_pack_gears.py
python tools/gear_texture/02_grayscale.py
python tools/gear_texture/03_darken.py
python tools/gear_texture/04_blur.py
```

The outputs are saved under `Art/Generated/GearTexture/`. `01_pack_gears.py` uses a
seeded random layout and rotation, so its output remains reproducible. It includes
partially cropped border gears and allows slight gear interlocking (including small
gears). To make another random layout, change `RANDOM_SEED` in that script.

To revise the darkness or blur without editing a file, pass command-line options:

```powershell
python tools/gear_texture/03_darken.py --brightness 0.44
python tools/gear_texture/04_blur.py --radius 6.5
```

Run the blur stage after every new darkening setting. Darkening is applied only to the
gears; the pure-white background is preserved. The source gear assets are never
modified.
