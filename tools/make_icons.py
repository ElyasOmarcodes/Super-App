#!/usr/bin/env python3
"""
Draws the launcher icon and writes it into every platform slot.

The mark is the eight-point star of Islamic book illumination with the letter
qaf at its centre, in the same jade-on-parchment palette the app uses.

Run from the repository root:  python3 tools/make_icons.py
"""

import json
import math
import os
import struct

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
APP = os.path.join(ROOT, 'app')
FONT = os.path.join(APP, 'assets', 'fonts', 'Amiri-Bold.ttf')

PARCHMENT_TOP = (251, 247, 239)
PARCHMENT_BOTTOM = (237, 228, 211)
JADE = (15, 110, 92)
GOLD = (185, 138, 60)

SUPERSAMPLE = 8


def draw_icon(size: int, background: bool = True) -> Image.Image:
    """Renders the mark at `size` pixels, supersampled then downscaled."""
    s = size * SUPERSAMPLE
    image = Image.new('RGBA', (s, s), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)

    if background:
        # A soft vertical parchment gradient, drawn a row at a time.
        for y in range(s):
            t = y / max(s - 1, 1)
            colour = tuple(
                round(a + (b - a) * t)
                for a, b in zip(PARCHMENT_TOP, PARCHMENT_BOTTOM)
            )
            draw.line([(0, y), (s, y)], fill=colour + (255,))

    centre = s / 2
    radius = s * 0.40

    def star(rotation: float, scale: float, colour, width: float):
        points = []
        for i in range(16):
            angle = rotation + i * math.pi / 8
            r = radius * scale * (1.0 if i % 2 == 0 else 0.62)
            points.append((centre + math.cos(angle) * r, centre + math.sin(angle) * r))
        draw.polygon(points, outline=colour, width=max(1, round(width)))

    star(-math.pi / 2, 1.00, JADE + (110,), s * 0.012)
    star(-math.pi / 2 + math.pi / 8, 0.80, GOLD + (170,), s * 0.010)
    draw.ellipse(
        [centre - radius * 0.54, centre - radius * 0.54,
         centre + radius * 0.54, centre + radius * 0.54],
        outline=JADE + (90,), width=max(1, round(s * 0.008)),
    )

    font = ImageFont.truetype(FONT, int(s * 0.44))
    glyph = 'ق'
    box = draw.textbbox((0, 0), glyph, font=font)
    draw.text(
        (centre - (box[0] + box[2]) / 2, centre - (box[1] + box[3]) / 2),
        glyph, font=font, fill=JADE + (255,),
    )

    return image.resize((size, size), Image.LANCZOS)


def write_png(path: str, size: int, background: bool = True):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    icon = draw_icon(size, background)
    if background:
        flat = Image.new('RGB', icon.size, PARCHMENT_TOP)
        flat.paste(icon, mask=icon.split()[3])
        flat.save(path, 'PNG', optimize=True)
    else:
        icon.save(path, 'PNG', optimize=True)
    print(f'  {os.path.relpath(path, ROOT)}  {size}px')


def android():
    print('android')
    for folder, size in [
        ('mipmap-mdpi', 48), ('mipmap-hdpi', 72), ('mipmap-xhdpi', 96),
        ('mipmap-xxhdpi', 144), ('mipmap-xxxhdpi', 192),
    ]:
        write_png(
            os.path.join(APP, 'android/app/src/main/res', folder, 'ic_launcher.png'),
            size,
        )


def ios():
    print('ios')
    icon_set = os.path.join(APP, 'ios/Runner/Assets.xcassets/AppIcon.appiconset')
    with open(os.path.join(icon_set, 'Contents.json'), encoding='utf-8') as handle:
        contents = json.load(handle)
    for entry in contents['images']:
        points = float(entry['size'].split('x')[0])
        scale = int(entry.get('scale', '1x').rstrip('x'))
        # iOS icons must be fully opaque, with no alpha channel at all.
        write_png(os.path.join(icon_set, entry['filename']), round(points * scale))


def windows():
    print('windows')
    target = os.path.join(APP, 'windows/runner/resources/app_icon.ico')
    sizes = [16, 24, 32, 48, 64, 128, 256]
    images = [draw_icon(size) for size in sizes]
    images[0].save(target, format='ICO', sizes=[(s, s) for s in sizes],
                   append_images=images[1:])
    print(f'  {os.path.relpath(target, ROOT)}  {sizes}')


def preview():
    path = os.path.join(ROOT, 'docs', 'icon.png')
    write_png(path, 512)


if __name__ == '__main__':
    android()
    ios()
    windows()
    preview()
