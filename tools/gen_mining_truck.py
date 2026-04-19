"""
Automated Mining Truck - top-down pixel art sprite
Command & Conquer inspired: bold silhouette, chunky vehicle,
olive/khaki military colours, visible cab + dump bed + wheels.
48x32 pixels, south-facing (facing down toward camera).
"""
from PIL import Image, ImageDraw

W, H = 48, 32

TRANSPARENT   = (0, 0, 0, 0)
SHADOW        = (0, 0, 0, 120)

# Truck palette
OUTLINE       = (20, 18, 14, 255)
CHASSIS_DARK  = (52, 58, 32, 255)   # dark olive
CHASSIS_MID   = (74, 84, 46, 255)   # main olive body
CHASSIS_LIGHT = (100, 114, 62, 255) # lit panel
CHASSIS_HILIT = (124, 140, 78, 255) # highlight
CAB_DARK      = (42, 50, 28, 255)
CAB_MID       = (62, 72, 40, 255)
CAB_GLASS     = (100, 160, 180, 255)
CAB_GLASS_HI  = (160, 210, 225, 255)
BED_DARK      = (38, 44, 24, 255)
BED_MID       = (58, 66, 36, 255)
BED_RIM       = (80, 92, 50, 255)
WHEEL_DARK    = (24, 22, 20, 255)
WHEEL_MID     = (44, 40, 36, 255)
WHEEL_HILIT   = (70, 64, 56, 255)
EXHAUST       = (60, 56, 50, 255)
LIGHT_AMBER   = (220, 160, 40, 255)
LIGHT_WHITE   = (240, 235, 210, 255)
ARMOR_DARK    = (44, 40, 26, 255)
ARMOR_MID     = (66, 60, 38, 255)
DIRT          = (80, 68, 44, 255)

def px(img, x, y, c):
    if 0 <= x < W and 0 <= y < H:
        img.putpixel((x, y), c)

def hline(img, x, y, w, c):
    for i in range(w): px(img, x+i, y, c)

def vline(img, x, y, h, c):
    for i in range(h): px(img, x, y+i, c)

def rect(img, x, y, w, h, c):
    for dy in range(h):
        for dx in range(w):
            px(img, x+dx, y+dy, c)

def make_truck():
    img = Image.new("RGBA", (W, H), TRANSPARENT)

    # ── Shadow (ground shadow beneath vehicle) ──
    shadow = Image.new("RGBA", (W, H), TRANSPARENT)
    for y in range(22, 32):
        alpha = int(100 * (y - 22) / 9)
        for x in range(6, 42):
            shadow.putpixel((x, y), (0, 0, 0, alpha))
    img = Image.alpha_composite(img, shadow)

    # ── WHEELS (drawn first, peeking from under body) ──
    # Front-left wheel
    wheel_coords = [
        (6,5),(7,5),(8,5),(6,6),(7,6),(8,6),(9,6),
        (5,7),(6,7),(7,7),(8,7),(9,7),(5,8),(6,8),(7,8),(8,8),(9,8),
        (6,9),(7,9),(8,9),(6,10),(7,10),(8,10),
    ]
    for (x,y) in wheel_coords:
        px(img, x, y, WHEEL_MID)
    for (x,y) in [(6,5),(7,5),(5,7),(5,8)]:
        px(img, x, y, WHEEL_HILIT)
    for (x,y) in [(8,9),(9,8),(9,6),(8,5)]:
        px(img, x, y, WHEEL_DARK)
    # Hub
    rect(img, 7, 7, 2, 2, WHEEL_HILIT)

    # Front-right wheel (mirror)
    for (x,y) in wheel_coords:
        nx = W - 1 - x
        px(img, nx, y, WHEEL_MID)
    for (x,y) in [(6,5),(7,5),(5,7),(5,8)]:
        px(img, W-1-x, y, WHEEL_DARK)
    for (x,y) in [(8,9),(9,8),(9,6),(8,5)]:
        px(img, W-1-x, y, WHEEL_HILIT)
    rect(img, W-9, 7, 2, 2, WHEEL_HILIT)

    # Rear-left wheel
    rear_wheel = [
        (6,19),(7,19),(8,19),(6,20),(7,20),(8,20),(9,20),
        (5,21),(6,21),(7,21),(8,21),(9,21),(5,22),(6,22),(7,22),(8,22),(9,22),
        (6,23),(7,23),(8,23),(6,24),(7,24),(8,24),
    ]
    for (x,y) in rear_wheel:
        px(img, x, y, WHEEL_MID)
    for (x,y) in [(6,19),(7,19),(5,21),(5,22)]:
        px(img, x, y, WHEEL_HILIT)
    for (x,y) in [(8,23),(9,22),(9,20),(8,19)]:
        px(img, x, y, WHEEL_DARK)
    rect(img, 7, 21, 2, 2, WHEEL_HILIT)

    # Rear-right wheel
    for (x,y) in rear_wheel:
        nx = W - 1 - x
        px(img, nx, y, WHEEL_MID)
    for (x,y) in [(6,19),(7,19),(5,21),(5,22)]:
        px(img, W-1-x, y, WHEEL_DARK)
    for (x,y) in [(8,23),(9,22),(9,20),(8,19)]:
        px(img, W-1-x, y, WHEEL_HILIT)
    rect(img, W-9, 21, 2, 2, WHEEL_HILIT)

    # ── CHASSIS / BODY ──
    # Main body block
    rect(img, 8, 2, 32, 28, CHASSIS_MID)

    # Left side panel darker
    rect(img, 8, 2, 3, 28, CHASSIS_DARK)
    # Right side panel darker
    rect(img, 37, 2, 3, 28, CHASSIS_DARK)

    # Top edge highlight
    hline(img, 9, 2, 30, CHASSIS_LIGHT)
    hline(img, 10, 3, 28, CHASSIS_HILIT)

    # Bottom shadow strip
    hline(img, 9, 28, 30, CHASSIS_DARK)
    hline(img, 10, 29, 28, OUTLINE)

    # Outline around whole body
    for x in range(8, 40):
        px(img, x, 2, OUTLINE)
        px(img, x, 29, OUTLINE)
    for y in range(2, 30):
        px(img, 8, y, OUTLINE)
        px(img, 39, y, OUTLINE)

    # ── CAB (front, top portion of sprite) ──
    rect(img, 11, 4, 26, 10, CAB_MID)
    # Cab roof lighter
    rect(img, 12, 4, 24, 4, CAB_DARK)
    # Windscreen glass
    rect(img, 15, 5, 18, 5, CAB_GLASS)
    hline(img, 15, 5, 18, CAB_GLASS_HI)
    vline(img, 15, 5, 5, CAB_GLASS_HI)
    # Cab outline
    for x in range(11, 37):
        px(img, x, 4, OUTLINE)
        px(img, x, 13, OUTLINE)
    for y in range(4, 14):
        px(img, 11, y, OUTLINE)
        px(img, 36, y, OUTLINE)
    # Cab divider line from body
    hline(img, 11, 14, 26, CHASSIS_DARK)

    # ── HEADLIGHTS ──
    px(img, 12, 3, LIGHT_AMBER)
    px(img, 13, 3, LIGHT_WHITE)
    px(img, 34, 3, LIGHT_AMBER)
    px(img, 35, 3, LIGHT_WHITE)

    # ── DUMP BED (rear portion) ──
    rect(img, 11, 15, 26, 13, BED_MID)
    # Bed floor darker
    rect(img, 12, 16, 24, 10, BED_DARK)
    # Bed rim highlights
    hline(img, 11, 15, 26, BED_RIM)
    vline(img, 11, 15, 13, BED_RIM)
    vline(img, 36, 15, 13, BED_RIM)
    # Bed ribs (detail lines across bed floor)
    for bx in [17, 22, 27, 32]:
        vline(img, bx, 16, 10, BED_DARK)
    # Bed outline
    for x in range(11, 37):
        px(img, x, 27, OUTLINE)
    for y in range(15, 28):
        px(img, 11, y, OUTLINE)
        px(img, 36, y, OUTLINE)

    # ── EXHAUST PIPE ──
    rect(img, 36, 4, 2, 6, EXHAUST)
    px(img, 36, 4, OUTLINE)
    px(img, 37, 4, OUTLINE)
    px(img, 37, 3, OUTLINE)
    px(img, 36, 3, CHASSIS_DARK)

    # ── ARMOR PLATING detail ──
    # Front bumper
    rect(img, 10, 2, 28, 2, ARMOR_MID)
    hline(img, 10, 2, 28, ARMOR_DARK)
    hline(img, 10, 1, 28, OUTLINE)
    # Small antenna
    px(img, 14, 1, EXHAUST)
    px(img, 14, 0, OUTLINE)

    # ── DIRT / WEAR marks on bed ──
    for (x,y) in [(14,19),(20,22),(28,18),(30,21),(16,23)]:
        px(img, x, y, DIRT)

    return img

truck = make_truck()
truck.save("C:/Users/grima/Documents/VoidYield/assets/sprites/vehicles/mining_truck.png")

truck2x = truck.resize((W*2, H*2), Image.NEAREST)
truck2x.save("C:/Users/grima/Documents/VoidYield/assets/sprites/vehicles/mining_truck_2x.png")

truck4x = truck.resize((W*4, H*4), Image.NEAREST)
truck4x.save("C:/Users/grima/Documents/VoidYield/assets/sprites/vehicles/mining_truck_4x.png")

print("Mining truck done!")
print("  mining_truck.png     (48x32)")
print("  mining_truck_2x.png  (96x64)")
print("  mining_truck_4x.png  (192x128)")
