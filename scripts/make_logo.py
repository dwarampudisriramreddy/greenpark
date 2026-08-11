#!/usr/bin/env python3
"""Generate a simple Green Park logo (green leaf mark + wordmark)."""
from PIL import Image, ImageDraw, ImageFont

SIZE = 1024
IMG = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
D = ImageDraw.Draw(IMG)

GREEN = (34, 139, 34)
DARK = (20, 90, 30)
CREAM = (250, 248, 240)

# soft green circle backdrop with a subtle ring
D.ellipse([96, 96, 928, 928], fill=GREEN)
D.ellipse([140, 140, 884, 884], outline=(255, 255, 255, 60), width=6)

# leaf (drawn as a set of overlapping ellipses)
def leaf(cx, cy, rx, ry, rot_deg, color):
    layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    l = ImageDraw.Draw(layer)
    l.ellipse([cx - rx, cy - ry, cx + rx, cy + ry], fill=color)
    layer = layer.rotate(rot_deg, resample=Image.BICUBIC, center=(cx, cy))
    IMG.alpha_composite(layer)

# main leaf
leaf(512, 420, 150, 90, -18, CREAM)
leaf(512, 430, 130, 78, 12, (235, 228, 210))
# veins
D.line([480, 380, 540, 430], fill=(120, 160, 120), width=6)
D.line([505, 395, 545, 400], fill=(120, 160, 120), width=5)
D.line([520, 430, 555, 445], fill=(120, 160, 120), width=5)
D.line([495, 450, 530, 470], fill=(120, 160, 120), width=5)

# wordmark
try:
    f_small = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSerif-Bold.ttf", 78)
    f_big = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSerif-Bold.ttf", 92)
    f_sub = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSansCondensed-Bold.ttf", 44)
except Exception:
    f_small = f_big = f_sub = ImageFont.load_default()

def center_text(text, y, font, fill):
    w = D.textlength(text, font=font)
    D.text(((SIZE - w) / 2, y), text, font=font, fill=fill)

center_text("GREEN", 600, f_small, CREAM)
center_text("PARK", 690, f_big, CREAM)
D.rounded_rectangle([SIZE/2 - 130, 830, SIZE/2 + 130, 836], radius=3, fill=(255, 255, 255, 90))
center_text("FAMILY RESTAURANT", 860, f_sub, (235, 228, 210))

IMG.save("/tmp/greenpark-imgs/logo.png")
IMG.save("/tmp/greenpark-imgs/logo-transparent.png")
print("logo saved")
