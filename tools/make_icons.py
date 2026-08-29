#!/usr/bin/env python3
"""
Draws the launcher icon and writes it into every platform slot.

The mark is the letter qaf on the same violet gradient the word-of-the-day
card wears, inside a ring broken by one bright arc — the still frame of the
turning indicator the app opens with, so the icon and the splash screen are
recognisably the same object.

Run from the repository root:  python3 tools/make_icons.py
"""

import json
import math
import os

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
APP = os.path.join(ROOT, 'app')
FONT = os.path.join(APP, 'assets', 'fonts', 'Vazirmatn-Bold.ttf')

# QamusTheme.gradient(QamusTheme.violet), evaluated: violet lightened 12%
# towards white at the top corner, darkened 26% towards #120C2E at the bottom.
GRADIENT_TOP = (140, 112, 255)
GRADIENT_BOTTOM = (96, 71, 201)

SUPERSAMPLE = 8


def _diagonal_wash(s: int) -> Image.Image:
    """The card's own gradient: top-start to bottom-end, corner to corner.

    Built small and scaled up — a 64-pixel ramp resampled to a 4096-pixel icon
    is indistinguishable from shading every pixel, and finishes instantly.
    """
    n = 64
    small = Image.new('RGBA', (n, n))
    pixels = small.load()
    for y in range(n):
        for x in range(n):
            t = (x + y) / (2 * (n - 1))
            pixels[x, y] = _lerp(GRADIENT_TOP, GRADIENT_BOTTOM, t) + (255,)
    return small.resize((s, s), Image.BICUBIC)


def draw_icon(size: int, background: bool = True) -> Image.Image:
    """Renders the mark at `size` pixels, supersampled then downscaled."""
    s = size * SUPERSAMPLE
    image = Image.new('RGBA', (s, s), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)

    if background:
        image.paste(_diagonal_wash(s), (0, 0))

    centre = s / 2
    ring = s * 0.40
    stroke = max(1, round(s * 0.042))

    # The full ring, faint: the indicator's track.
    draw.ellipse(
        [centre - ring, centre - ring, centre + ring, centre + ring],
        outline=(255, 255, 255, 64), width=stroke,
    )
    # And the arc riding on it, bright — one frame of the animation.
    draw.arc(
        [centre - ring, centre - ring, centre + ring, centre + ring],
        start=-100, end=45, fill=(255, 255, 255, 235), width=stroke,
    )

    font = ImageFont.truetype(FONT, int(s * 0.42))
    glyph = 'ق'
    box = draw.textbbox((0, 0), glyph, font=font)
    draw.text(
        (centre - (box[0] + box[2]) / 2, centre - (box[1] + box[3]) / 2),
        glyph, font=font, fill=(255, 255, 255, 255),
    )

    return image.resize((size, size), Image.LANCZOS)


def _lerp(a, b, t):
    return tuple(round(x + (y - x) * t) for x, y in zip(a, b))


def write_png(path: str, size: int, background: bool = True):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    icon = draw_icon(size, background)
    if background:
        # iOS refuses an icon with an alpha channel, so it is flattened onto
        # the gradient's own top colour rather than onto white.
        flat = Image.new('RGB', icon.size, GRADIENT_TOP)
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
    write_png(os.path.join(ROOT, 'docs', 'icon.png'), 512)


if __name__ == '__main__':
    android()
    ios()
    windows()
    preview()
