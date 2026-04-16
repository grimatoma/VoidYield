"""Generate miner_frames.tres — a SpriteFrames resource that slices
miner_spritesheet.png into 8 directional walk cycles plus mining and
unloading animations.

The layout must stay in sync with generate_miner_spritesheet.py:
    FRAME = 20 px; rows 0..7 = walk N/NE/E/SE/S/SW/W/NW (4 frames each);
    row 8 = mining (6); row 9 = unloading (6).
"""
import os

FRAME = 20
DIRS = ["n", "ne", "e", "se", "s", "sw", "w", "nw"]
SHEET_PATH = "res://assets/sprites/drones/miner_spritesheet.png"

# Animation table: (name, row, frame_count, speed_fps, loop)
ANIMS = []
for i, d in enumerate(DIRS):
    ANIMS.append((f"walk_{d}", i, 4, 8.0, True))
ANIMS.append(("mining", 8, 6, 12.0, True))
ANIMS.append(("unloading", 9, 6, 8.0, False))


def atlas_id(anim_name, frame_idx):
    return f"atl_{anim_name}_{frame_idx}"


def build_tres():
    lines = []
    # load_steps = 1 (ext) + N (subresources)
    total_frames = sum(count for (_, _, count, _, _) in ANIMS)
    load_steps = 1 + total_frames + 1  # +1 for the resource itself
    lines.append(f'[gd_resource type="SpriteFrames" load_steps={load_steps} format=3]')
    lines.append("")
    lines.append(
        f'[ext_resource type="Texture2D" path="{SHEET_PATH}" id="1_sheet"]'
    )
    lines.append("")

    # Sub-resources (one AtlasTexture per frame)
    for name, row, count, _speed, _loop in ANIMS:
        for f in range(count):
            x = f * FRAME
            y = row * FRAME
            sid = atlas_id(name, f)
            lines.append(f'[sub_resource type="AtlasTexture" id="{sid}"]')
            lines.append('atlas = ExtResource("1_sheet")')
            lines.append(f"region = Rect2({x}, {y}, {FRAME}, {FRAME})")
            lines.append("")

    # Main resource
    lines.append("[resource]")
    lines.append("animations = [")
    anim_entries = []
    for name, _row, count, speed, loop in ANIMS:
        frame_entries = []
        for f in range(count):
            sid = atlas_id(name, f)
            frame_entries.append(
                f'{{\n"duration": 1.0,\n"texture": SubResource("{sid}")\n}}'
            )
        frames_block = ", ".join(frame_entries)
        loop_str = "true" if loop else "false"
        anim_entries.append(
            "{\n"
            f'"frames": [{frames_block}],\n'
            f'"loop": {loop_str},\n'
            f'"name": &"{name}",\n'
            f'"speed": {speed}\n'
            "}"
        )
    lines.append(", ".join(anim_entries))
    lines.append("]")
    return "\n".join(lines) + "\n"


if __name__ == "__main__":
    out_dir = os.path.join(os.path.dirname(__file__), "..", "..", "assets", "sprites", "drones")
    out_dir = os.path.abspath(out_dir)
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, "miner_frames.tres")
    with open(out_path, "w", encoding="utf-8", newline="\n") as f:
        f.write(build_tres())
    print(f"Wrote {out_path}")
