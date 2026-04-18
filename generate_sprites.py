#!/usr/bin/env python3
"""Generate isometric pixel art sprites for VoidYield."""

from PIL import Image, ImageDraw
import os, math, random

random.seed(42)

ROOT = os.path.dirname(os.path.abspath(__file__))
SPR  = os.path.join(ROOT, "assets", "sprites")

def mkdirs(*dirs):
    for d in dirs:
        os.makedirs(d, exist_ok=True)

mkdirs(
    os.path.join(SPR, "ground"),
    os.path.join(SPR, "ores"),
    os.path.join(SPR, "buildings"),
    os.path.join(SPR, "player"),
)

def save(img, *parts):
    p = os.path.join(SPR, *parts)
    img.save(p)
    print(f"  {os.path.relpath(p, ROOT)}")


# ──────────────────────────────────────────────────────────────
# HELPERS
# ──────────────────────────────────────────────────────────────

def shadow_ellipse(draw, cx, cy, rx, ry, alpha=90):
    draw.ellipse([cx-rx, cy-ry, cx+rx, cy+ry], fill=(0, 0, 0, alpha))


def organic_poly(cx, cy, rx, ry, n=12, jitter=0.18):
    """Return a list of (x,y) points forming an organic polygon."""
    pts = []
    for i in range(n):
        a = math.tau * i / n
        jr = 1.0 + random.uniform(-jitter, jitter)
        pts.append((cx + rx * jr * math.cos(a),
                     cy + ry * jr * math.sin(a)))
    return pts


def int_pts(pts):
    return [(int(x), int(y)) for x, y in pts]


def iso_box(draw, bx, by, fw, sw, bh,
            c_top, c_front, c_side, c_edge=None):
    """
    Draw a 2.5-D isometric box.
    bx, by = top-left of the front face
    fw = front face width
    sw = side face visible width (and vertical offset for roof)
    bh = front face height
    """
    # Front face
    draw.rectangle([bx, by, bx+fw, by+bh], fill=c_front)
    # Top face (parallelogram)
    top = [(bx,       by),
           (bx+fw,    by),
           (bx+fw+sw, by-sw//2),
           (bx+sw,    by-sw//2)]
    draw.polygon(top, fill=c_top)
    # Right side face
    side = [(bx+fw,    by),
            (bx+fw+sw, by-sw//2),
            (bx+fw+sw, by+bh-sw//2),
            (bx+fw,    by+bh)]
    draw.polygon(side, fill=c_side)
    if c_edge:
        # Outline the top face edges
        draw.line([top[0], top[1]], fill=c_edge, width=1)
        draw.line([top[1], top[2]], fill=c_edge, width=1)
        draw.line([top[2], top[3]], fill=c_edge, width=1)
        draw.line([top[3], top[0]], fill=c_edge, width=1)
    return top, side


# ──────────────────────────────────────────────────────────────
# GROUND TILES  (64 × 32 isometric diamond)
# ──────────────────────────────────────────────────────────────

def make_tile(base, edge_light, edge_dark, noise):
    W, H = 64, 32
    img  = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    diamond = [(32, 0), (63, 15), (32, 31), (0, 15)]
    draw.polygon(diamond, fill=base)
    # Top-left bright edge
    draw.line([(32,0),(63,15)], fill=edge_light, width=1)
    draw.line([(32,0),(0,15)],  fill=edge_light, width=1)
    # Bottom-right dark edge
    draw.line([(63,15),(32,31)], fill=edge_dark, width=1)
    draw.line([(0,15),(32,31)],  fill=edge_dark, width=1)
    # Scatter noise pixels inside diamond
    pix = img.load()
    for _ in range(90):
        x = random.randint(2, 61)
        y = random.randint(1, 30)
        if abs(x-32)/32.0 + abs(y-15)/15.0 < 0.92 and pix[x,y][3] > 0:
            pix[x, y] = random.choice(noise)
    return img

save(make_tile(
    base=(58, 54, 50, 255), edge_light=(80, 75, 68, 255),
    edge_dark=(35, 32, 30, 255),
    noise=[(52,48,44,255),(48,44,40,255),(65,60,55,255),(42,38,36,255)]),
    "ground", "tile_asteroid.png")

save(make_tile(
    base=(32, 42, 58, 255), edge_light=(52, 68, 90, 255),
    edge_dark=(18, 26, 40, 255),
    noise=[(28,38,54,255),(22,32,48,255),(38,50,68,255),(18,28,44,255)]),
    "ground", "tile_planet_b.png")


# ──────────────────────────────────────────────────────────────
# ORE NODES  (48 × 48 RGBA)
# ──────────────────────────────────────────────────────────────

def rock_lump(draw, cx, cy, rx, ry, body, highlight, shadow_c):
    pts = int_pts(organic_poly(cx, cy, rx, ry))
    draw.polygon(pts, fill=body)
    # top-left highlight
    hl = int_pts(organic_poly(cx - rx*0.2, cy - ry*0.25,
                              rx*0.35, ry*0.28, n=8, jitter=0.1))
    draw.polygon(hl, fill=highlight)
    # bottom-right shadow strip
    sh = int_pts(organic_poly(cx + rx*0.15, cy + ry*0.2,
                              rx*0.4, ry*0.32, n=8, jitter=0.1))
    draw.polygon(sh, fill=shadow_c)


def crystal_spire(draw, bx, by, w, h, body, edge, tip):
    pts = [(bx - w, by), (bx + w, by),
           (bx + w//2, by - h*2//3), (bx, by - h), (bx - w//2, by - h*2//3)]
    draw.polygon(pts, fill=body)
    draw.line([(bx-w, by), (bx, by-h)], fill=edge, width=1)
    draw.ellipse([bx-2, by-h-2, bx+2, by-h+2], fill=tip)


# ── Vorax (common grey-brown) ──
def make_ore_vorax():
    img = Image.new("RGBA", (48, 48), (0,0,0,0))
    draw = ImageDraw.Draw(img)
    shadow_ellipse(draw, 24, 41, 16, 5)
    rock_lump(draw, 21, 24, 14, 12, (98,85,70,255), (125,110,90,255), (68,58,46,255))
    rock_lump(draw, 32, 30, 10,  9, (88,76,62,255), (112,98,80,255), (60,52,40,255))
    rock_lump(draw, 14, 32, 9,   8, (106,92,75,255),(130,114,94,255),(74,64,50,255))
    return img

# ── Krysite (rare purple crystal) ──
def make_ore_krysite():
    img = Image.new("RGBA", (48, 48), (0,0,0,0))
    draw = ImageDraw.Draw(img)
    shadow_ellipse(draw, 24, 41, 14, 4, 100)
    rock_lump(draw, 24, 34, 13, 9, (38,12,72,255),(50,18,95,255),(22,6,45,255))
    crystal_spire(draw, 18, 32, 4, 20, (85,22,168,255),(130,55,210,255),(210,110,255,255))
    crystal_spire(draw, 27, 34, 3, 24, (95,28,178,255),(138,62,218,255),(220,120,255,255))
    crystal_spire(draw, 34, 32, 3, 16, (78,18,155,255),(118,48,200,255),(195,95,250,255))
    # glow scatter
    pix = img.load()
    for _ in range(14):
        x, y = random.randint(10,38), random.randint(8,38)
        if pix[x,y][3] > 60:
            pix[x,y] = (175, 90, 255, 255)
    return img

# ── Crystal Shards (cyan-blue) ──
def make_ore_shards():
    img = Image.new("RGBA", (48, 48), (0,0,0,0))
    draw = ImageDraw.Draw(img)
    shadow_ellipse(draw, 24, 41, 12, 4, 80)
    rock_lump(draw, 24, 34, 11, 8, (14,32,58,255),(22,48,82,255),(8,20,40,255))
    crystal_spire(draw, 16, 33, 3, 14, (22,115,185,255),(55,178,235,255),(145,230,255,255))
    crystal_spire(draw, 23, 35, 3, 18, (28,125,195,255),(60,188,242,255),(155,238,255,255))
    crystal_spire(draw, 30, 33, 2, 13, (18,108,178,255),(50,170,228,255),(138,225,255,255))
    crystal_spire(draw, 36, 34, 2, 10, (15,95,165,255),(44,158,215,255),(130,218,252,255))
    return img

# ── Aethite (teal/green) ──
def make_ore_aethite():
    img = Image.new("RGBA", (48, 48), (0,0,0,0))
    draw = ImageDraw.Draw(img)
    shadow_ellipse(draw, 24, 41, 16, 5, 90)
    rock_lump(draw, 20, 26, 13, 11, (14,62,55,255),(20,88,76,255),(8,38,34,255))
    rock_lump(draw, 31, 31,  9,  8, (12,55,48,255),(18,80,68,255),(6,32,28,255))
    crystal_spire(draw, 22, 30, 3, 18, (25,148,118,255),(55,195,158,255),(88,228,192,255))
    crystal_spire(draw, 30, 32, 2, 12, (20,135,108,255),(48,185,148,255),(78,220,182,255))
    return img

# ── Voidstone (dark violet) ──
def make_ore_voidstone():
    img = Image.new("RGBA", (48, 48), (0,0,0,0))
    draw = ImageDraw.Draw(img)
    shadow_ellipse(draw, 24, 41, 17, 6, 120)
    rock_lump(draw, 24, 24, 16, 14, (18,5,36,255), (28,8,55,255), (10,2,22,255))
    rock_lump(draw, 14, 32, 10,  9, (15,3,30,255), (22,6,45,255), (8,1,18,255))
    rock_lump(draw, 34, 30,  9,  8, (20,5,40,255), (30,10,58,255),(12,3,25,255))
    # void energy sparks
    draw2 = ImageDraw.Draw(img)
    pix = img.load()
    for _ in range(12):
        x, y = random.randint(10,38), random.randint(8,38)
        if pix[x,y][3] > 60:
            pix[x,y] = (88, 28, 148, 220)
    return img

save(make_ore_vorax(),   "ores", "ore_vorax.png")
save(make_ore_krysite(), "ores", "ore_krysite.png")
save(make_ore_shards(),  "ores", "ore_shards.png")
save(make_ore_aethite(), "ores", "ore_aethite.png")
save(make_ore_voidstone(),"ores","ore_voidstone.png")


# ──────────────────────────────────────────────────────────────
# BUILDINGS
# ──────────────────────────────────────────────────────────────

# ── Storage Depot ──
def make_storage_depot():
    W, H = 72, 72
    img  = Image.new("RGBA", (W, H), (0,0,0,0))
    draw = ImageDraw.Draw(img)
    shadow_ellipse(draw, 36, 66, 26, 7)
    bx, by = 8, 22
    fw, sw, bh = 46, 14, 34
    iso_box(draw, bx, by, fw, sw, bh,
            c_top=(85, 76, 68, 255), c_front=(68, 60, 54, 255),
            c_side=(48, 42, 38, 255), c_edge=(100, 90, 80, 255))
    # Fill gauge slots on front face
    for i in range(3):
        gx = bx + 6 + i * 14
        draw.rectangle([gx, by+8, gx+8, by+bh-6], fill=(45, 40, 36, 255))
        draw.rectangle([gx+1, by+bh-16, gx+7, by+bh-7], fill=(180, 120, 30, 220))
    # Tank dome on roof
    tx, ty = bx + fw//2 + sw//2, by - sw//2 - 4
    draw.ellipse([tx-10, ty-6, tx+10, ty+6], fill=(95, 86, 76, 255))
    draw.ellipse([tx-7,  ty-4, tx+7,  ty+4], fill=(108, 98, 86, 255))
    # Pipe on right side
    draw.rectangle([bx+fw+2, by+6, bx+fw+8, by+bh-4], fill=(55, 48, 42, 255))
    return img

# ── Sell Terminal ──
def make_sell_terminal():
    W, H = 56, 80
    img  = Image.new("RGBA", (W, H), (0,0,0,0))
    draw = ImageDraw.Draw(img)
    shadow_ellipse(draw, 28, 74, 18, 5)
    bx, by = 6, 18
    fw, sw, bh = 36, 12, 52
    iso_box(draw, bx, by, fw, sw, bh,
            c_top=(62, 56, 48, 255), c_front=(50, 44, 38, 255),
            c_side=(35, 30, 26, 255), c_edge=(75, 68, 58, 255))
    # Gold screen on front
    sx, sy = bx+4, by+6
    draw.rectangle([sx, sy, sx+22, sy+28], fill=(185, 135, 22, 255))
    draw.rectangle([sx+1, sy+1, sx+21, sy+27], fill=(228, 178, 45, 255))
    draw.rectangle([sx+2, sy+2, sx+9,  sy+10], fill=(245, 205, 75, 200))
    # CR symbol as two rectangles
    draw.rectangle([sx+3, sy+14, sx+12, sy+22], fill=(180, 130, 20, 255))
    draw.rectangle([sx+14, sy+14, sx+20, sy+22], fill=(180, 130, 20, 255))
    # Keypad
    for r in range(2):
        for c in range(3):
            draw.rectangle([sx+3+c*6, sy+32+r*5, sx+7+c*6, sy+35+r*5],
                           fill=(60, 52, 44, 255))
    # Top indicator light
    draw.ellipse([bx+fw//2+sw//2-3, by-sw//2-8, bx+fw//2+sw//2+3, by-sw//2-2],
                 fill=(255, 220, 80, 255))
    return img

# ── Shop Terminal ──
def make_shop_terminal():
    W, H = 64, 88
    img  = Image.new("RGBA", (W, H), (0,0,0,0))
    draw = ImageDraw.Draw(img)
    shadow_ellipse(draw, 32, 82, 22, 6)
    bx, by = 6, 18
    fw, sw, bh = 42, 14, 58
    iso_box(draw, bx, by, fw, sw, bh,
            c_top=(56, 48, 40, 255), c_front=(44, 38, 30, 255),
            c_side=(30, 26, 20, 255), c_edge=(68, 60, 50, 255))
    # Main amber screen
    sx, sy = bx+4, by+6
    draw.rectangle([sx, sy, sx+28, sy+32], fill=(155, 105, 28, 255))
    draw.rectangle([sx+1, sy+1, sx+27, sy+31], fill=(198, 145, 48, 255))
    draw.rectangle([sx+2, sy+2, sx+10, sy+11], fill=(218, 168, 70, 200))
    # Secondary small screen
    draw.rectangle([sx, sy+36, sx+16, sy+48], fill=(125, 88, 22, 255))
    draw.rectangle([sx+1, sy+37, sx+15, sy+47], fill=(168, 120, 40, 255))
    # Buttons row
    for i in range(4):
        draw.rectangle([sx+i*6, sy+52, sx+i*6+4, sy+56], fill=(55, 48, 38, 255))
    # Right side vent slots
    for i in range(5):
        draw.line([(bx+fw+2, by+10+i*8), (bx+fw+sw-2, by+8+i*8-sw//4)],
                  fill=(22, 18, 14, 255), width=1)
    return img

# ── Drone Bay ──
def make_drone_bay():
    W, H = 76, 88
    img  = Image.new("RGBA", (W, H), (0,0,0,0))
    draw = ImageDraw.Draw(img)
    shadow_ellipse(draw, 38, 82, 28, 7)
    bx, by = 6, 16
    fw, sw, bh = 52, 16, 60
    iso_box(draw, bx, by, fw, sw, bh,
            c_top=(48, 56, 50, 255), c_front=(38, 46, 40, 255),
            c_side=(26, 32, 28, 255), c_edge=(60, 72, 62, 255))
    # Hangar door opening on front face
    dx = bx + 8
    draw.rectangle([dx, by+10, dx+26, by+bh-4], fill=(22, 28, 24, 255))
    draw.rectangle([dx+2, by+12, dx+24, by+bh-6], fill=(14, 18, 16, 255))
    # Door frame
    draw.line([(dx, by+10),(dx, by+bh-4)], fill=(55, 68, 58, 255), width=1)
    draw.line([(dx+26, by+10),(dx+26, by+bh-4)], fill=(55,68,58,255), width=1)
    draw.line([(dx, by+10),(dx+26, by+10)], fill=(55,68,58,255), width=1)
    # Teal accent strip on roof
    roof_y = by - sw//2 - 2
    draw.rectangle([bx+2, roof_y, bx+fw+sw-2, roof_y+3], fill=(62, 125, 102, 255))
    # Small drone silhouette inside
    dc = dx + 13
    draw.ellipse([dc-6, by+bh-22, dc+6, by+bh-16], fill=(55, 68, 58, 200))
    draw.ellipse([dc-2, by+bh-26, dc+2, by+bh-22], fill=(48, 60, 52, 200))
    return img

# ── Spaceship ──
def make_spaceship():
    W, H = 80, 96
    img  = Image.new("RGBA", (W, H), (0,0,0,0))
    draw = ImageDraw.Draw(img)
    shadow_ellipse(draw, 40, 90, 28, 7)
    # Launch pad base
    bx, by = 8, 72
    fw, sw, bh = 48, 16, 12
    iso_box(draw, bx, by, fw, sw, bh,
            c_top=(36, 36, 44, 255), c_front=(28, 28, 36, 255),
            c_side=(20, 20, 28, 255))
    # Exhaust ring on pad top
    pcx, pcy = bx + fw//2 + sw//2, by - sw//2 + 6
    draw.ellipse([pcx-14, pcy-5, pcx+14, pcy+5], fill=(24, 24, 32, 255))
    draw.ellipse([pcx-8,  pcy-3, pcx+8,  pcy+3], fill=(16, 16, 24, 255))
    # Rocket body
    rx, ry = W//2, by - sw//2
    # Fins
    draw.polygon([(rx-14, ry),(rx-10, ry-22),(rx-18, ry-8),(rx-20, ry+2)],
                 fill=(140, 140, 150, 255))
    draw.polygon([(rx+14, ry),(rx+10, ry-22),(rx+18, ry-8),(rx+20, ry+2)],
                 fill=(118, 118, 128, 255))
    # Nozzle bell
    draw.polygon([(rx-9, ry-2),(rx+9, ry-2),(rx+7, ry-14),(rx-7, ry-14)],
                 fill=(155, 155, 165, 255))
    # Main cylinder
    draw.rectangle([rx-10, ry-48, rx+10, ry-12], fill=(188, 188, 198, 255))
    draw.rectangle([rx-10, ry-48, rx-7,  ry-12], fill=(210, 210, 220, 255))
    draw.rectangle([rx+7,  ry-48, rx+10, ry-12], fill=(162, 162, 172, 255))
    # Red stripe
    draw.rectangle([rx-10, ry-28, rx+10, ry-24], fill=(220, 72, 58, 255))
    # Nose cone
    draw.polygon([(rx-10, ry-48),(rx+10, ry-48),(rx, ry-68)], fill=(200, 200, 210, 255))
    # Cockpit window
    draw.ellipse([rx-5, ry-60, rx+5, ry-50], fill=(100, 165, 255, 255))
    draw.ellipse([rx-3, ry-58, rx,   ry-54], fill=(160, 220, 255, 180))
    # Exhaust flames
    for i, col in enumerate([(200,130,20,220),(220,80,20,180),(200,200,60,160)]):
        fx = rx + (i-1)*5
        draw.polygon([(fx-3, ry-1),(fx+3, ry-1),(fx, ry+10)], fill=col)
    return img

# ── Launch Pad (Planet B) ──
def make_launch_pad():
    W, H = 80, 64
    img  = Image.new("RGBA", (W, H), (0,0,0,0))
    draw = ImageDraw.Draw(img)
    shadow_ellipse(draw, 40, 58, 26, 6)
    bx, by = 8, 44
    fw, sw, bh = 48, 16, 12
    iso_box(draw, bx, by, fw, sw, bh,
            c_top=(28, 44, 65, 255), c_front=(20, 34, 52, 255),
            c_side=(14, 24, 38, 255))
    pcx, pcy = bx + fw//2 + sw//2, by - sw//2 + 6
    # Landing circle markings
    draw.ellipse([pcx-16, pcy-6, pcx+16, pcy+6], outline=(62, 125, 185, 255), width=2)
    draw.ellipse([pcx-10, pcy-4, pcx+10, pcy+4], outline=(88, 165, 225, 255), width=1)
    # Indicator lights
    for a in range(0, 360, 45):
        ax = pcx + int(15 * math.cos(math.radians(a)))
        ay = pcy + int( 5 * math.sin(math.radians(a)))
        draw.ellipse([ax-2, ay-2, ax+2, ay+2], fill=(80, 205, 255, 255))
    # Up arrow
    draw.polygon([(pcx, pcy-4),(pcx-3, pcy),(pcx+3, pcy)], fill=(100, 210, 255, 255))
    return img

save(make_storage_depot(),  "buildings", "storage_depot.png")
save(make_sell_terminal(),  "buildings", "sell_terminal.png")
save(make_shop_terminal(),  "buildings", "shop_terminal.png")
save(make_drone_bay(),      "buildings", "drone_bay.png")
save(make_spaceship(),      "buildings", "spaceship.png")
save(make_launch_pad(),     "buildings", "launch_pad.png")


# ──────────────────────────────────────────────────────────────
# PLAYER  (32 × 48 RGBA, 4 iso directions)
# ──────────────────────────────────────────────────────────────

def make_player(direction="se"):
    W, H = 32, 48
    img  = Image.new("RGBA", (W, H), (0,0,0,0))
    draw = ImageDraw.Draw(img)
    cx   = W // 2

    # ── Shadow ──
    shadow_ellipse(draw, cx, H-6, 9, 4)

    # ── Boots ──
    lc, rc = (28,52,88,255), (22,42,70,255)
    if direction in ("sw","nw"):  lc, rc = rc, lc
    draw.rectangle([cx-6, H-16, cx-2, H-8],  fill=lc)
    draw.rectangle([cx+1, H-16, cx+5, H-8],  fill=rc)
    # boot sole
    draw.rectangle([cx-7, H-9,  cx-2, H-7],  fill=(18,32,55,255))
    draw.rectangle([cx+1, H-9,  cx+6, H-7],  fill=(18,32,55,255))

    # ── Suit Body ──
    draw.rectangle([cx-7, H-36, cx+7, H-14], fill=(45,75,132,255))
    draw.rectangle([cx-7, H-36, cx-4, H-14], fill=(65,102,168,255))  # highlight
    draw.rectangle([cx+4, H-36, cx+7, H-14], fill=(32,56,100,255))   # shadow
    # chest emblem
    draw.rectangle([cx-3, H-32, cx+3, H-27], fill=(30,55,98,255))
    draw.rectangle([cx-2, H-31, cx+2, H-28], fill=(80,140,220,255))

    # ── Backpack ──
    pack_col = (32,58,98,255)
    if direction in ("se","ne"):
        draw.rectangle([cx-10, H-36, cx-7, H-22], fill=pack_col)
    elif direction in ("sw","nw"):
        draw.rectangle([cx+7,  H-36, cx+10, H-22], fill=pack_col)

    # ── Arms ──
    arm_col = (38,65,118,255)
    draw.rectangle([cx-11, H-36, cx-8,  H-24], fill=arm_col)
    draw.rectangle([cx+8,  H-36, cx+11, H-24], fill=(28,50,92,255))

    # ── Neck ──
    draw.rectangle([cx-2, H-40, cx+2, H-36], fill=(30,30,30,255))

    # ── Helmet ──
    draw.ellipse([cx-8, H-50, cx+8, H-38], fill=(50,82,145,255))
    draw.rectangle([cx-8, H-46, cx+8, H-40], fill=(50,82,145,255))
    draw.rectangle([cx-8, H-44, cx-5, H-40], fill=(68,108,172,255))  # hl
    # Visor
    draw.ellipse([cx-6, H-48, cx+6, H-38],  fill=(100,185,245,220))
    draw.ellipse([cx-5, H-47, cx-1, H-42],  fill=(165,225,255,170))
    # Helmet trim
    draw.arc([cx-8, H-50, cx+8, H-38], 180, 360, fill=(72,112,175,255), width=1)
    # Helmet light
    lx = cx+4 if direction in ("se","ne") else cx-7
    draw.ellipse([lx-2, H-50, lx+2, H-46], fill=(255,225,100,255))

    return img

for d in ("se","sw","ne","nw"):
    save(make_player(d), "player", f"player_{d}.png")


# ──────────────────────────────────────────────────────────────
# DRONE SPRITESHEET  (120 × 200, 20×20 frames — replaces existing)
# ──────────────────────────────────────────────────────────────

def draw_drone_frame(draw, fx, fy, direction="s",
                     is_mining=False, is_unloading=False, frame=0):
    FW, FH = 20, 20
    cx, cy = fx + FW//2, fy + FH//2
    bob    = frame % 2  # 0 or 1 pixel hover bob

    # Shadow (stays on ground)
    draw.ellipse([cx-6, cy+3+bob, cx+6, cy+6+bob], fill=(0,0,0,90))

    # Disc rim (slightly below body)
    dy = -bob
    draw.ellipse([cx-7, cy-2+dy, cx+7, cy+3+dy], fill=(62,76,68,255))
    # Disc top face (lighter)
    draw.ellipse([cx-7, cy-4+dy, cx+7, cy+1+dy], fill=(98,118,108,255))
    # Dome
    draw.ellipse([cx-3, cy-7+dy, cx+3, cy-3+dy], fill=(78,96,86,255))
    draw.ellipse([cx-2, cy-7+dy, cx,   cy-5+dy], fill=(108,132,118,180))

    # Direction indicator LED
    DIR_OFFSET = {"n":(0,-5),"ne":(3,-4),"e":(5,-1),"se":(4,2),
                  "s":(0,3),"sw":(-4,2),"w":(-5,-1),"nw":(-3,-4)}
    ox, oy = DIR_OFFSET.get(direction, (0,2))
    draw.ellipse([cx+ox-2, cy+oy-2+dy, cx+ox+2, cy+oy+2+dy],
                 fill=(80,230,175,255))

    # Mining sparks
    if is_mining:
        cols = [(255,195,45,255),(255,140,25,220),(240,220,50,180)]
        for _ in range(3):
            sx = cx + random.randint(-6,6)
            sy = cy + random.randint(-7,3) + dy
            draw.point((sx, sy), fill=cols[frame % 3])

    # Unloading glow
    if is_unloading:
        gc = (55,205,152,180) if frame%2==0 else (85,225,172,160)
        draw.ellipse([cx-4, cy-5+dy, cx+4, cy+2+dy], fill=gc)


def make_drone_spritesheet():
    FW, FH = 20, 20
    COLS, ROWS = 6, 10
    img  = Image.new("RGBA", (FW*COLS, FH*ROWS), (0,0,0,0))
    draw = ImageDraw.Draw(img)

    DIRS = ["n","ne","e","se","s","sw","w","nw"]
    for row, d in enumerate(DIRS):
        for f in range(4):
            draw_drone_frame(draw, f*FW, row*FH, direction=d, frame=f)
    for f in range(6):
        draw_drone_frame(draw, f*FW, 8*FH, direction="s",
                         is_mining=True, frame=f)
    for f in range(6):
        draw_drone_frame(draw, f*FW, 9*FH, direction="sw",
                         is_unloading=True, frame=f)
    return img

save(make_drone_spritesheet(), "drones", "miner_spritesheet.png")

print("\n✓ All sprites generated.")
