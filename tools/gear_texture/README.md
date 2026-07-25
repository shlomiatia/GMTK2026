# Gear texture pipeline

Run these scripts from the repository root, in order:

```powershell
python tools/gear_texture/01_pack_gears.py
python tools/gear_texture/02_grayscale.py
python tools/gear_texture/03_darken.py
python tools/gear_texture/04_blur.py
```

The outputs are saved under `Art/Generated/GearTexture/`.  To revise the darkness
or blur, edit `BRIGHTNESS` in `03_darken.py` or `BLUR_RADIUS` in `04_blur.py`, then
run that stage and every stage after it.  The source gear assets are never modified.
