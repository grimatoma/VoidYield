"""Generate miner sprite sheet for ScoutDrone.

Layout (20x20 frames):
    Rows 0-7: 8 direction walk cycles (4 frames each)
        0: N, 1: NE, 2: E, 3: SE, 4: S, 5: SW, 6: W, 7: NW
    Row 8: mining animation (6 frames) - drill oscillates forward (facing E)
    Row 9: unloading animation (6 frames) - ore drops from hopper (facing S)

Total: 6 columns x 10 rows = 120x200 px
"""
import math
import os
from PIL import Image

FRAME = 20
COLS = 6
ROWS = 10
W = FRAME * COLS
H = FRAME * ROWS
CX = CY = FRAME // 2  # 10

# Palette — high contrast so direction reads at a glance
BG          = (0, 0, 0, 0)
OUTLINE     = (24, 26, 32, 255)
BODY_DARK   = (66, 72, 82, 255)
BODY_MID    = (118, 128, 140, 255)
BODY_LIGHT  = (170, 182, 196, 255)
ACCENT      = (46, 162, 202, 255)   # cyan accent stripe
ACCENT_HI   = (122, 214, 240, 255)
EYE         = (255, 196, 58, 255)
EYE_LIT     = (255, 240, 140, 255)
DRILL       = (198, 204, 214, 255)
DRILL_TIP   = (255, 255, 255, 255)
ORE         = (224, 122, 60, 255)
ORE_HI      = (255, 176, 98, 255)
SPARK       = (255, 230, 140, 255)
DUST        = (180, 160, 120, 200)


def blank_frame():
    return Image.new("RGBA", (FRAME, FRAME), BG)


def put_px(img, x, y, color):
    if 0 <= x < FRAME and 0 <= y < FRAME:
        img.putpixel((int(x), int(y)), color)


def disc(img, cx, cy, r, color):
    r2 = r * r + r
    for y in range(cy - r, cy + r + 1):
        for x in range(cx - r, cx + r + 1):
            dx = x - cx
            dy = y - cy
            if dx * dx + dy * dy <= r2:
                put_px(img, x, y, color)


def disc_outline(img, cx, cy, r, color):
    inner = r * r + r
    outer = (r + 1) * (r + 1) + (r + 1)
    for y in range(cy - r - 1, cy + r + 2):
        for x in range(cx - r - 1, cx + r + 2):
            dx = x - cx
            dy = y - cy
            d2 = dx * dx + dy * dy
            if inner < d2 <= outer:
                put_px(img, x, y, color)


def draw_miner(img, angle_deg, walk_frame=0, drill_extend=0, carrying=False):
    """Top-down mining drone centered at (CX,CY), facing angle_deg.

    angle_deg uses Godot convention: 0=East(+X), 90=South(+Y).
    """
    rad = math.radians(angle_deg)
    fx, fy = math.cos(rad), math.sin(rad)           # forward
    px, py = -math.sin(rad), math.cos(rad)          # right-of-forward

    # Body: chunky round chassis
    disc_outline(img, CX, CY, 5, OUTLINE)
    disc(img, CX, CY, 5, BODY_DARK)
    disc(img, CX, CY, 4, BODY_MID)

    # Accent stripe running perpendicular to forward (across the "shoulders")
    for t in (-3, -2, 2, 3):
        ax = CX + round(px * t)
        ay = CY + round(py * t)
        # pull slightly back so the stripe doesn't cover the drill base
        ax -= round(fx * 1)
        ay -= round(fy * 1)
        put_px(img, ax, ay, ACCENT)

    # Highlight: small bright pixel on the rear-right quadrant
    hl_x = CX - round(fx * 2) - round(px * 1)
    hl_y = CY - round(fy * 2) - round(py * 1)
    put_px(img, hl_x, hl_y, BODY_LIGHT)

    # Rear hopper (opposite of forward): small dark cube on the back
    rx = CX - round(fx * 4)
    ry = CY - round(fy * 4)
    put_px(img, rx, ry, OUTLINE)
    rx2 = CX - round(fx * 3)
    ry2 = CY - round(fy * 3)
    if carrying:
        put_px(img, rx2, ry2, ORE)
        # ore highlight
        put_px(img, rx2 - round(py), ry2 + round(px), ORE_HI)
    else:
        put_px(img, rx2, ry2, BODY_DARK)

    # Treads: two 3-pixel bars on either flank, shifted by walk_frame
    offsets = [0, 1, 0, -1]
    wobble = offsets[walk_frame % 4]
    for side in (-1, 1):
        bx = CX + round(px * side * 4)
        by = CY + round(py * side * 4)
        w = wobble if side == 1 else -wobble
        for t in (-1, 0, 1):
            ex = bx + round(fx * (t + w))
            ey = by + round(fy * (t + w))
            put_px(img, ex, ey, OUTLINE)

    # Cockpit eye, forward-biased inside the body
    ex = CX + round(fx * 2)
    ey = CY + round(fy * 2)
    put_px(img, ex, ey, EYE_LIT)
    # surrounding eye socket
    put_px(img, ex + round(px), ey + round(py), EYE)
    put_px(img, ex - round(px), ey - round(py), EYE)

    # Drill arm: starts just outside the body (radius 5) and extends forward
    drill_start = 6
    drill_len = 2 + drill_extend
    for t in range(drill_start, drill_start + drill_len):
        dx = CX + round(fx * t)
        dy = CY + round(fy * t)
        color = DRILL_TIP if t == drill_start + drill_len - 1 else DRILL
        put_px(img, dx, dy, color)
    # Drill base mount (wider at the body) — two flanking pixels in OUTLINE
    b_t = drill_start - 1
    bx0 = CX + round(fx * b_t)
    by0 = CY + round(fy * b_t)
    put_px(img, bx0 + round(px), by0 + round(py), OUTLINE)
    put_px(img, bx0 - round(px), by0 - round(py), OUTLINE)


DIRECTIONS = [
    (0, -90),   # N  (up)
    (1, -45),   # NE
    (2,   0),   # E  (right)
    (3,  45),   # SE
    (4,  90),   # S  (down)
    (5, 135),   # SW
    (6, 180),   # W  (left)
    (7, 225),   # NW
]


def build_sheet():
    sheet = Image.new("RGBA", (W, H), BG)

    # Walk cycles
    for row, angle in DIRECTIONS:
        for frame in range(4):
            cell = blank_frame()
            draw_miner(cell, angle, walk_frame=frame, drill_extend=0, carrying=False)
            sheet.paste(cell, (frame * FRAME, row * FRAME), cell)

    # Mining animation (facing East) — drill pumps in and out
    mine_extends = [0, 1, 2, 3, 2, 1]
    for i, ext in enumerate(mine_extends):
        cell = blank_frame()
        draw_miner(cell, 0, walk_frame=0, drill_extend=ext, carrying=False)
        tip_x = CX + (6 + 2 + ext - 1)  # last drawn drill pixel x
        tip_y = CY
        if ext >= 2:
            # Spark burst orthogonal to drill
            put_px(cell, tip_x + 1, tip_y - 1, SPARK)
            put_px(cell, tip_x + 1, tip_y + 1, SPARK)
        if ext == 3:
            put_px(cell, tip_x + 2, tip_y, SPARK)
            # Impact dust puff under body
            put_px(cell, CX - 1, CY + 6, DUST)
            put_px(cell, CX + 1, CY + 6, DUST)
        sheet.paste(cell, (i * FRAME, 8 * FRAME), cell)

    # Unloading animation (facing South) — hopper opens, ore drops forward
    # Forward for angle 90 = (0,1) i.e. +Y / downward in image.
    for i in range(6):
        cell = blank_frame()
        carrying = i < 3
        draw_miner(cell, 90, walk_frame=0, drill_extend=0, carrying=carrying)

        if i == 1:
            # Hopper lid cracking open (rear is North/up of body)
            put_px(cell, CX, CY - 6, BODY_LIGHT)
        if i == 2:
            # Ore emerging at rear
            put_px(cell, CX, CY - 5, ORE_HI)
        if i == 3:
            # Ore falling beside drone
            put_px(cell, CX, CY - 3, ORE)
            put_px(cell, CX + 1, CY - 3, ORE_HI)
        if i == 4:
            # Ore landed below drone (it has forward-deposited)
            put_px(cell, CX - 1, CY + 7, ORE)
            put_px(cell, CX, CY + 7, ORE_HI)
            put_px(cell, CX + 1, CY + 7, ORE)
        if i == 5:
            # Ore pile settled
            put_px(cell, CX - 2, CY + 8, ORE)
            put_px(cell, CX, CY + 8, ORE_HI)
            put_px(cell, CX + 2, CY + 8, ORE)
            put_px(cell, CX - 1, CY + 7, ORE)
            put_px(cell, CX + 1, CY + 7, ORE)

        sheet.paste(cell, (i * FRAME, 9 * FRAME), cell)

    return sheet


if __name__ == "__main__":
    out_dir = os.path.join(os.path.dirname(__file__), "..", "..", "assets", "sprites", "drones")
    out_dir = os.path.abspath(out_dir)
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, "miner_spritesheet.png")
    sheet = build_sheet()
    sheet.save(out_path)
    print(f"Wrote {out_path} ({sheet.size[0]}x{sheet.size[1]})")
