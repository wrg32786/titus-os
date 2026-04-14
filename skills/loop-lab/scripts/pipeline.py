"""
Full loop-lab pipeline: text-to-video → glue → RIFE → dissolve → 60s loop.

Usage:
    python pipeline.py --tag "ski_chalet" --base-prompt "..." --glue-prompt "..."
    python pipeline.py --tag "ski_chalet" --base-prompt-file base.txt --glue-prompt-file glue.txt

Environment:
    LTX_API_KEY         — required
    LOOP_LAB_RIFE       — path to Practical-RIFE repo (optional, auto-detected)
    LOOP_LAB_OUTPUT     — output directory (optional, defaults to ./output)
"""
import os, sys, subprocess, re, argparse, shutil

# Add this script's directory to path for sibling imports
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from ltx_api import text_to_video, image_to_video_glue
from frame_tools import read_endpoint, compute_ssim

FPS = 24
N_INTERP = 4
XFADE_DURATION = 0.44


def find_ffmpeg():
    """Locate ffmpeg binary — check imageio-ffmpeg first, then PATH."""
    try:
        import imageio_ffmpeg
        return imageio_ffmpeg.get_ffmpeg_exe()
    except ImportError:
        pass
    # Fallback: assume ffmpeg is on PATH
    return "ffmpeg"


def find_rife():
    """Locate Practical-RIFE repo root."""
    env_path = os.environ.get("LOOP_LAB_RIFE", "").strip()
    if env_path and os.path.isfile(os.path.join(env_path, "train_log", "flownet.pkl")):
        return env_path
    # Common locations
    for candidate in [
        os.path.expanduser("~/Downloads/Practical-RIFE"),
        os.path.expanduser("~/Practical-RIFE"),
        os.path.join(os.path.dirname(__file__), "..", "..", "..", "Practical-RIFE"),
    ]:
        if os.path.isfile(os.path.join(candidate, "train_log", "flownet.pkl")):
            return candidate
    raise RuntimeError(
        "Practical-RIFE not found. Set LOOP_LAB_RIFE env var or install to ~/Downloads/Practical-RIFE"
    )


def find_prife_wrapper():
    """Locate the RIFE inference wrapper script."""
    local = os.path.join(os.path.dirname(os.path.abspath(__file__)), "prife_interp.py")
    if os.path.isfile(local):
        return local
    raise RuntimeError(f"prife_interp.py not found at {local}")


def rife_bridge(name, frame_a, frame_b, work_dir, ffmpeg):
    """Generate N_INTERP RIFE frames between frame_a and frame_b, return mp4 path."""
    import cv2
    pair_dir = os.path.join(work_dir, f"{name}_pair")
    os.makedirs(pair_dir, exist_ok=True)
    pa = os.path.join(pair_dir, "a.png")
    pb = os.path.join(pair_dir, "b.png")
    cv2.imwrite(pa, frame_a)
    cv2.imwrite(pb, frame_b)

    interp_dir = os.path.join(work_dir, f"{name}_interp")
    os.makedirs(interp_dir, exist_ok=True)

    prife = find_prife_wrapper()
    r = subprocess.run(
        [sys.executable, prife, pa, pb, interp_dir, str(N_INTERP)],
        capture_output=True, text=True
    )
    if r.returncode != 0:
        raise RuntimeError(f"RIFE failed for {name}: {r.stderr[-400:]}")

    mp4 = os.path.join(work_dir, f"{name}.mp4")
    subprocess.run([
        ffmpeg, "-y", "-hide_banner", "-loglevel", "error",
        "-framerate", str(FPS), "-i", os.path.join(interp_dir, "%04d.png"),
        "-c:v", "libx264", "-preset", "fast", "-crf", "18",
        "-pix_fmt", "yuv420p", mp4
    ], check=True)
    return mp4


def run_pipeline(tag, base_prompt, glue_prompt, output_dir=None, model="ltx-2-3-pro"):
    """Execute the full pipeline. Returns dict with paths and metrics."""
    import cv2

    ffmpeg = find_ffmpeg()
    output_dir = output_dir or os.environ.get("LOOP_LAB_OUTPUT", os.path.expanduser("~/Downloads"))
    work_dir = os.path.join(output_dir, f"loop_lab_{tag}")
    os.makedirs(work_dir, exist_ok=True)

    print(f"\n=== loop-lab: {tag} ===", flush=True)
    print(f"  base prompt: {len(base_prompt)} chars", flush=True)
    print(f"  glue prompt: {len(glue_prompt)} chars", flush=True)

    # Step 1: text-to-video base
    base_mp4 = os.path.join(work_dir, "base.mp4")
    print("\n[1/6] text-to-video base clip (6s, Pro, static)", flush=True)
    if os.path.isfile(base_mp4) and os.path.getsize(base_mp4) > 1_000_000:
        print("  [cached]", flush=True)
    else:
        ok, elapsed, rid, size = text_to_video(base_prompt, base_mp4, model=model)
        if not ok:
            print(f"  FAILED: {rid}", flush=True)
            return None
        print(f"  [OK] {elapsed:.1f}s  {size:.1f}MB  req={rid}", flush=True)

    # Step 2: extract frames
    print("\n[2/6] Extract first + last frames", flush=True)
    first = read_endpoint(base_mp4, "first")
    last = read_endpoint(base_mp4, "last")
    H, W = first.shape[:2]
    print(f"  {W}x{H}", flush=True)

    # Step 3: glue clip
    glue_mp4 = os.path.join(work_dir, "glue.mp4")
    print("\n[3/6] image-to-video glue clip (6s, frame-anchored)", flush=True)
    if os.path.isfile(glue_mp4) and os.path.getsize(glue_mp4) > 1_000_000:
        print("  [cached]", flush=True)
    else:
        ok, elapsed, rid, size = image_to_video_glue(first, last, glue_prompt, glue_mp4, model=model)
        if not ok:
            print(f"  FAILED: {rid}", flush=True)
            return None
        print(f"  [OK] {elapsed:.1f}s  {size:.1f}MB  req={rid}", flush=True)

    glue_first = read_endpoint(glue_mp4, "first")
    glue_last = read_endpoint(glue_mp4, "last")
    if glue_first.shape[:2] != (H, W):
        glue_first = cv2.resize(glue_first, (W, H))
    if glue_last.shape[:2] != (H, W):
        glue_last = cv2.resize(glue_last, (W, H))

    # Step 4: SSIM
    s_mid = compute_ssim(last, glue_first)
    s_loop = compute_ssim(glue_last, first)
    print(f"\n[4/6] SSIM  mid={s_mid:.4f}  loop={s_loop:.4f}", flush=True)

    # Step 5: RIFE bridges
    print("\n[5/6] RIFE v4.25 bridges (4 frames each)", flush=True)
    bm = rife_bridge("bridge_mid", last, glue_first, work_dir, ffmpeg)
    bl = rife_bridge("bridge_loop", glue_last, first, work_dir, ffmpeg)

    # Normalize source clips
    base_norm = os.path.join(work_dir, "base_norm.mp4")
    glue_norm = os.path.join(work_dir, "glue_norm.mp4")
    for src, dst in [(base_mp4, base_norm), (glue_mp4, glue_norm)]:
        subprocess.run([
            ffmpeg, "-y", "-hide_banner", "-loglevel", "error",
            "-i", src, "-vf", f"fps={FPS},scale={W}:{H}",
            "-c:v", "libx264", "-preset", "fast", "-crf", "18",
            "-pix_fmt", "yuv420p", dst
        ], check=True)

    # Step 6: concat with xfade dissolve + loop
    print(f"\n[6/6] Concat with {XFADE_DURATION}s dissolve + loop to 60s", flush=True)
    segs = [base_norm, bm, glue_norm, bl]

    # Get segment durations
    durs = []
    for seg in segs:
        probe = subprocess.run([ffmpeg, "-hide_banner", "-i", seg], capture_output=True, text=True)
        m = re.search(r"Duration:\s*(\d+):(\d+):([\d.]+)", probe.stderr)
        d = int(m.group(1)) * 3600 + int(m.group(2)) * 60 + float(m.group(3))
        durs.append(d)

    # Build xfade chain
    inputs = " ".join(f'-i "{s}"' for s in segs)
    o1 = durs[0] - XFADE_DURATION
    o2 = durs[0] + durs[1] - 2 * XFADE_DURATION
    o3 = durs[0] + durs[1] + durs[2] - 3 * XFADE_DURATION

    fc = (
        f"[0][1]xfade=transition=fade:duration={XFADE_DURATION}:offset={o1:.3f}[a];"
        f"[a][2]xfade=transition=fade:duration={XFADE_DURATION}:offset={o2:.3f}[b];"
        f"[b][3]xfade=transition=fade:duration={XFADE_DURATION}:offset={o3:.3f}[c]"
    )

    chain = os.path.join(work_dir, "chain.mp4")
    cmd = (
        f'"{ffmpeg}" -y -hide_banner -loglevel error {inputs} '
        f'-filter_complex "{fc}" -map "[c]" '
        f'-c:v libx264 -preset fast -crf 18 -pix_fmt yuv420p -r {FPS} "{chain}"'
    )
    subprocess.run(cmd, shell=True, check=True)

    # Get chain duration + loop
    probe = subprocess.run([ffmpeg, "-hide_banner", "-i", chain], capture_output=True, text=True)
    m = re.search(r"Duration:\s*(\d+):(\d+):([\d.]+)", probe.stderr)
    chain_dur = int(m.group(1)) * 3600 + int(m.group(2)) * 60 + float(m.group(3))
    loops = max(1, int(round(60.0 / chain_dur)))

    final = os.path.join(output_dir, f"loop_lab_{tag}_60s.mp4")
    subprocess.run([
        ffmpeg, "-y", "-hide_banner", "-loglevel", "error",
        "-stream_loop", str(loops - 1), "-i", chain,
        "-t", "60", "-c", "copy", final
    ], check=True)

    print(f"\n  Chain: {chain_dur:.2f}s, looped {loops}x", flush=True)
    print(f"  SSIM: mid={s_mid:.4f}  loop={s_loop:.4f}", flush=True)
    print(f"  Final: {final}", flush=True)

    return {
        "tag": tag,
        "ssim_mid": s_mid,
        "ssim_loop": s_loop,
        "chain_duration": chain_dur,
        "final": final,
        "work_dir": work_dir,
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="loop-lab pipeline")
    parser.add_argument("--tag", required=True, help="Test variant name")
    parser.add_argument("--base-prompt", help="Base prompt text")
    parser.add_argument("--glue-prompt", help="Glue prompt text")
    parser.add_argument("--base-prompt-file", help="File containing base prompt")
    parser.add_argument("--glue-prompt-file", help="File containing glue prompt")
    parser.add_argument("--model", default="ltx-2-3-pro", help="LTX model")
    parser.add_argument("--output", help="Output directory")
    args = parser.parse_args()

    base_prompt = args.base_prompt
    glue_prompt = args.glue_prompt
    if args.base_prompt_file:
        with open(args.base_prompt_file) as f:
            base_prompt = f.read().strip()
    if args.glue_prompt_file:
        with open(args.glue_prompt_file) as f:
            glue_prompt = f.read().strip()

    if not base_prompt or not glue_prompt:
        parser.error("Provide both --base-prompt and --glue-prompt (or --*-prompt-file)")

    run_pipeline(args.tag, base_prompt, glue_prompt, output_dir=args.output, model=args.model)
