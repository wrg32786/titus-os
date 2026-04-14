---
name: loop-lab
description: Pre-production testing lab for seamless loop video. Generates LTX text-to-video base + image-to-video glue, applies Practical-RIFE v4.25 bridges + 0.44s dissolve, loops to 60s, reports SSIM. Use for prompt iteration and A/B testing BEFORE shipping to FlowStack.
user-invocable: true
---

# /loop-lab

Local seamless-loop video testing pipeline. Generates, stitches, bridges, and measures loop quality end-to-end without touching FlowStack production code.

## When to Use

- Test a new prompt, scene, or parameter before FlowStack deployment
- A/B compare prompt variants with SSIM metrics
- Validate a new scene type (interior, nature, human) for loop quality
- Generate a 60s preview of what production would output

## Capabilities

| Command | What it does |
|---------|-------------|
| `/loop-lab test <tag> <scene>` | Full pipeline: prompt → LTX → RIFE → dissolve → 60s loop + SSIM |
| `/loop-lab prompt <scene>` | Generate doctrine-formatted base + glue prompts only |
| `/loop-lab bridge <frame_a> <frame_b>` | Standalone RIFE v4.25 interpolation between two frames |
| `/loop-lab compare <file1> <file2> ...` | SSIM ranking across multiple test outputs |
| `/loop-lab corpus [add\|query\|export]` | Manage validated prompt library |

## Requirements

Installed via pip (Python 3.12+):
- `opencv-python-headless` — frame extraction, SSIM
- `scikit-image` — structural_similarity metric
- `torch` + `torchvision` — Practical-RIFE inference
- `imageio-ffmpeg` — bundled ffmpeg binary

External:
- Practical-RIFE v4.25 repo with model weights (`flownet.pkl`)
- LTX API key (env var `LTX_API_KEY` or prompted at runtime)

## Configuration (environment variables)

```bash
export LTX_API_KEY="ltxv_..."           # LTX direct API key (required)
export LOOP_LAB_RIFE="path/to/Practical-RIFE"  # Practical-RIFE repo root (optional, auto-detected)
export LOOP_LAB_OUTPUT="path/to/output"  # Output directory (optional, defaults to ~/Downloads)
```

## Pipeline Architecture

```
1. POST /text-to-video → 6s base clip (LTX-native prompt, static camera, no audio)
2. Extract first + last frames (cv2, JPEG q95 base64)
3. POST /image-to-video → 6s glue clip (last_frame as image_uri, first_frame as last_frame_uri)
4. RIFE v4.25 → 4-frame bridge at base_end → glue_start
5. RIFE v4.25 → 4-frame bridge at glue_end → base_start
6. Concat: base + RIFE_mid + glue + RIFE_loop with 0.44s xfade dissolve at each join
7. Stream-loop to 60s
8. Report SSIM at both seams
```

## Prompting Doctrine (baked into prompt generator)

- LTX-native flowing narrative paragraph (not structured blocks)
- Photorealistic anchor + scene description + camera lock + motion policy + loop hint
- Camera lock in BOTH base and glue: "Camera is locked onto a tripod, completely immobile"
- 2-3 allowed motion elements max
- No `negative_prompt` (not in LTX API)
- Base prompt: scene-focused, 1500-2000 chars
- Glue prompt: SHORT, loop-closure focused, 800-1200 chars
- Fold negatives into positive language ("air is completely still" not "no wind")

## API Reference

- Base URL: `https://api.ltx.video/v1`
- Auth: `Authorization: Bearer <LTX_API_KEY>`
- Model: `ltx-2-3-pro` (default) or `ltx-2-3-fast`
- `camera_motion` enum: `dolly_in|dolly_out|dolly_left|dolly_right|jib_up|jib_down|static|focus_shift`
- Response: MP4 body directly (no polling)
- Frame payloads: JPEG q95 base64 data URI (PNG exceeds nginx body limit)

## SSIM Interpretation

```
> 0.95   Near-perfect — RIFE morph invisible
0.85-0.95  Good — 4-frame RIFE bridge is cosmetic
0.75-0.85  Decent — production-acceptable
0.65-0.75  Marginal — visible morph possible
< 0.65   Bad — need better source or different approach
```

## Scene Type Performance (validated baselines)

| Scene Type | Typical Loop SSIM | Notes |
|-----------|-------------------|-------|
| Interior + fireplace | 0.82-0.87 | Best. Bounded geometry. |
| Human subject (meditation) | 0.74-0.75 | Good. Calm-breath doctrine required. |
| Open nature (stream, forest) | 0.68-0.74 | Harder. Water/fog motion drifts. |

## Scripts

| File | Purpose |
|------|---------|
| `scripts/pipeline.py` | Full end-to-end pipeline (test command) |
| `scripts/ltx_api.py` | LTX API helpers (auth, post, download) |
| `scripts/frame_tools.py` | Frame extraction, SSIM, JPEG encoding |
| `scripts/prife_interp.py` | Practical-RIFE v4.25 inference wrapper |
| `corpus/corpus.json` | Validated prompt library |

## Related Skills

- `/ltx-test` → DEPRECATED, use `/loop-lab test` instead
- `/ltx-prompt` → DEPRECATED, use `/loop-lab prompt` instead
- `/rife-bridge` → DEPRECATED, use `/loop-lab bridge` instead
- `/ltx-compare` → DEPRECATED, use `/loop-lab compare` instead
- `/ltx-corpus` → DEPRECATED, use `/loop-lab corpus` instead
