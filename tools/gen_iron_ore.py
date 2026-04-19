"""
Iron Ore Patch - tileable 32x32 pixel art sprite
Factorio-inspired: chunky rocks with embedded metallic ore veins.
Designed to tile seamlessly in any grid arrangement.
"""
from PIL import Image, ImageDraw
import random

W, H = 32, 32

# Palette
TRANSPARENT   = (0, 0, 0, 0)
ROCK_DARKEST  = (28, 24, 20, 255)   # deep shadow
ROCK_DARK     = (48, 42, 36, 255)   # dark rock
ROCK_MID      = (68, 60, 50, 255)   # mid rock
ROCK_LIGHT    = (90, 80, 66, 255)   # lit rock face
ROCK_HILIGHT  = (112, 100, 82, 255) # specular highlight
ORE_DARK      = (42, 62, 88, 255)   # deep ore
ORE_MID       = (62, 94, 130, 255)  # main ore colour (iron blue)
ORE_LIGHT     = (86, 130, 172, 255) # lit ore face
ORE_HILIGHT   = (140, 190, 220, 255)# ore specular
EDGE_SHADOW   = (18, 15, 12, 255)   # border/ground shadow
GROUND        = (38, 34, 28, 255)   # dark earthy ground fill

def px(img, x, y, c):
    if 0 <= x < W and 0 <= y < H:
        img.putpixel((x, y), c)

def rect(img, x, y, w, h, c):
    for dy in range(h):
        for dx in range(w):
            px(img, x+dx, y+dy, c)

def make_ore_patch():
    img = Image.new("RGBA", (W, H), TRANSPARENT)

    # --- Ground fill (full tile so it tiles cleanly) ---
    for y in range(H):
        for x in range(W):
            # Slight noise-based variation
            v = ((x * 7 + y * 13) % 5)
            if v == 0:
                img.putpixel((x, y), ROCK_DARKEST)
            elif v < 3:
                img.putpixel((x, y), GROUND)
            else:
                img.putpixel((x, y), ROCK_DARK)

    # --- Rock chunk 1 (top-left area) ---
    # Base shape
    rock1 = [
        (4,3),(5,3),(6,3),(7,3),(8,3),
        (3,4),(4,4),(5,4),(6,4),(7,4),(8,4),(9,4),
        (3,5),(4,5),(5,5),(6,5),(7,5),(8,5),(9,5),(10,5),
        (4,6),(5,6),(6,6),(7,6),(8,6),(9,6),(10,6),
        (5,7),(6,7),(7,7),(8,7),(9,7),
        (6,8),(7,8),(8,8),
    ]
    for (x,y) in rock1:
        px(img, x, y, ROCK_MID)
    # Light face (top-left lit)
    for (x,y) in [(5,3),(6,3),(4,4),(5,4),(4,5),(5,5)]:
        px(img, x, y, ROCK_LIGHT)
    for (x,y) in [(5,3),(4,4)]:
        px(img, x, y, ROCK_HILIGHT)
    # Shadow (bottom-right)
    for (x,y) in [(9,5),(10,5),(9,6),(10,6),(8,7),(9,7),(7,8),(8,8)]:
        px(img, x, y, ROCK_DARK)
    for (x,y) in [(10,5),(10,6),(9,7),(8,8)]:
        px(img, x, y, ROCK_DARKEST)
    # Ore vein embedded in rock1
    ore1 = [(6,4),(7,4),(6,5),(7,5),(8,5),(7,6),(8,6)]
    for (x,y) in ore1:
        px(img, x, y, ORE_MID)
    for (x,y) in [(6,4),(6,5)]:
        px(img, x, y, ORE_LIGHT)
    px(img, 6, 4, ORE_HILIGHT)
    for (x,y) in [(8,5),(8,6)]:
        px(img, x, y, ORE_DARK)

    # --- Rock chunk 2 (right-center) ---
    rock2 = [
        (18,6),(19,6),(20,6),(21,6),(22,6),
        (17,7),(18,7),(19,7),(20,7),(21,7),(22,7),(23,7),
        (17,8),(18,8),(19,8),(20,8),(21,8),(22,8),(23,8),(24,8),
        (18,9),(19,9),(20,9),(21,9),(22,9),(23,9),(24,9),
        (19,10),(20,10),(21,10),(22,10),(23,10),
        (20,11),(21,11),(22,11),
    ]
    for (x,y) in rock2:
        px(img, x, y, ROCK_MID)
    for (x,y) in [(18,6),(19,6),(17,7),(18,7),(17,8),(18,8)]:
        px(img, x, y, ROCK_LIGHT)
    for (x,y) in [(18,6),(17,7)]:
        px(img, x, y, ROCK_HILIGHT)
    for (x,y) in [(23,8),(24,8),(23,9),(24,9),(22,10),(23,10),(21,11),(22,11)]:
        px(img, x, y, ROCK_DARK)
    for (x,y) in [(24,8),(24,9),(23,10),(22,11)]:
        px(img, x, y, ROCK_DARKEST)
    # Ore in rock2
    ore2 = [(19,7),(20,7),(19,8),(20,8),(21,8),(20,9),(21,9)]
    for (x,y) in ore2:
        px(img, x, y, ORE_MID)
    for (x,y) in [(19,7),(19,8)]:
        px(img, x, y, ORE_LIGHT)
    px(img, 19, 7, ORE_HILIGHT)
    for (x,y) in [(21,8),(21,9)]:
        px(img, x, y, ORE_DARK)

    # --- Rock chunk 3 (bottom-center) ---
    rock3 = [
        (10,18),(11,18),(12,18),(13,18),(14,18),
        (9,19),(10,19),(11,19),(12,19),(13,19),(14,19),(15,19),
        (9,20),(10,20),(11,20),(12,20),(13,20),(14,20),(15,20),(16,20),
        (10,21),(11,21),(12,21),(13,21),(14,21),(15,21),(16,21),
        (11,22),(12,22),(13,22),(14,22),(15,22),
        (12,23),(13,23),(14,23),
    ]
    for (x,y) in rock3:
        px(img, x, y, ROCK_MID)
    for (x,y) in [(10,18),(11,18),(9,19),(10,19),(9,20),(10,20)]:
        px(img, x, y, ROCK_LIGHT)
    for (x,y) in [(10,18),(9,19)]:
        px(img, x, y, ROCK_HILIGHT)
    for (x,y) in [(15,20),(16,20),(15,21),(16,21),(14,22),(15,22),(13,23),(14,23)]:
        px(img, x, y, ROCK_DARK)
    for (x,y) in [(16,20),(16,21),(15,22),(14,23)]:
        px(img, x, y, ROCK_DARKEST)
    # Ore in rock3
    ore3 = [(11,19),(12,19),(11,20),(12,20),(13,20),(12,21),(13,21)]
    for (x,y) in ore3:
        px(img, x, y, ORE_MID)
    for (x,y) in [(11,19),(11,20)]:
        px(img, x, y, ORE_LIGHT)
    px(img, 11, 19, ORE_HILIGHT)
    for (x,y) in [(13,20),(13,21)]:
        px(img, x, y, ORE_DARK)

    # --- Small scattered ore pebbles ---
    pebbles = [
        (14,4,ORE_MID),(15,4,ORE_DARK),(14,5,ORE_LIGHT),
        (24,14,ORE_MID),(25,14,ORE_DARK),(24,15,ORE_LIGHT),
        (3,14,ORE_MID),(4,14,ORE_DARK),
        (20,24,ORE_MID),(21,24,ORE_DARK),(20,25,ORE_LIGHT),
        (6,26,ORE_MID),(7,26,ORE_DARK),
        (27,4,ORE_DARK),(28,4,ORE_MID),
        (2,28,ORE_MID),(3,28,ORE_DARK),
        (28,26,ORE_MID),(29,26,ORE_DARK),
    ]
    for (x,y,c) in pebbles:
        px(img, x, y, c)

    # --- Edge-tile ground variation for tileability ---
    # Slightly darken edges so seams blend
    for x in range(W):
        px(img, x, 0, ROCK_DARKEST)
        px(img, x, H-1, ROCK_DARKEST)
    for y in range(H):
        px(img, 0, y, ROCK_DARKEST)
        px(img, W-1, y, ROCK_DARKEST)

    return img

# Save 1× and 2× preview
ore = make_ore_patch()
ore.save("C:/Users/grima/Documents/VoidYield/assets/sprites/resources/iron_ore_patch.png")

# 2× upscale (nearest-neighbour, pixel-perfect)
ore2x = ore.resize((W*2, H*2), Image.NEAREST)
ore2x.save("C:/Users/grima/Documents/VoidYield/assets/sprites/resources/iron_ore_patch_2x.png")

# 4× for preview
ore4x = ore.resize((W*4, H*4), Image.NEAREST)
ore4x.save("C:/Users/grima/Documents/VoidYield/assets/sprites/resources/iron_ore_patch_4x.png")

# Tiling demo - 3×3 grid to show seamless tiling
demo = Image.new("RGBA", (W*3, H*3), (0,0,0,255))
for ty in range(3):
    for tx in range(3):
        demo.paste(ore, (tx*W, ty*H))
demo8x = demo.resize((W*3*4, H*3*4), Image.NEAREST)
demo8x.save("C:/Users/grima/Documents/VoidYield/assets/sprites/resources/iron_ore_patch_tiled_preview.png")

print("Iron ore patch done!")
print("  iron_ore_patch.png           (32x32)")
print("  iron_ore_patch_2x.png        (64x64)")
print("  iron_ore_patch_4x.png        (128x128)")
print("  iron_ore_patch_tiled_preview.png (3x3 tiling demo at 4x)")
