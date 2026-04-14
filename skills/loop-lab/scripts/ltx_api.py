"""
LTX Video API helpers for loop-lab.
Sanitized — no hardcoded keys or paths. Uses env vars.
"""
import os, json, base64, time
import urllib.request, urllib.error
import cv2

API_BASE = os.environ.get("LTX_API_BASE", "https://api.ltx.video/v1")

def get_api_key():
    key = os.environ.get("LTX_API_KEY", "").strip()
    if not key:
        raise RuntimeError(
            "LTX_API_KEY not set. Set via: export LTX_API_KEY='ltxv_...'\n"
            "Get a key at https://console.ltx.video/"
        )
    return key

def post_ltx(path, payload, out_path):
    """POST to LTX API, stream MP4 response to out_path. Returns (success, elapsed, request_id)."""
    url = f"{API_BASE}{path}"
    body = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(url, data=body, headers={
        "Authorization": f"Bearer {get_api_key()}",
        "Content-Type": "application/json",
    }, method="POST")
    t0 = time.time()
    try:
        with urllib.request.urlopen(req, timeout=600) as resp:
            with open(out_path, "wb") as fh:
                while True:
                    chunk = resp.read(1 << 16)
                    if not chunk:
                        break
                    fh.write(chunk)
            rid = resp.headers.get("x-request-id", "?")
        elapsed = time.time() - t0
        size_mb = os.path.getsize(out_path) / 1e6
        return True, elapsed, rid, size_mb
    except urllib.error.HTTPError as e:
        body_text = e.read().decode("utf-8", errors="replace")[:500]
        return False, time.time() - t0, f"HTTP {e.code}: {body_text}", 0
    except Exception as e:
        return False, time.time() - t0, f"{type(e).__name__}: {e}", 0

def text_to_video(prompt, out_path, model="ltx-2-3-pro", duration=6,
                  resolution="1920x1080", fps=24, camera_motion="static"):
    """Generate a video from text prompt. Returns (success, elapsed, request_id, size_mb)."""
    return post_ltx("/text-to-video", {
        "prompt": prompt,
        "model": model,
        "duration": duration,
        "resolution": resolution,
        "fps": fps,
        "camera_motion": camera_motion,
        "generate_audio": False,
    }, out_path)

def image_to_video_glue(first_frame, last_frame, prompt, out_path,
                        model="ltx-2-3-pro", duration=6,
                        resolution="1920x1080", fps=24, camera_motion="static"):
    """Generate a glue video from last_frame → first_frame (loop closure).
    first_frame, last_frame: numpy BGR arrays (cv2 format).
    """
    return post_ltx("/image-to-video", {
        "image_uri": frame_to_data_uri(last_frame),
        "last_frame_uri": frame_to_data_uri(first_frame),
        "prompt": prompt,
        "model": model,
        "duration": duration,
        "resolution": resolution,
        "fps": fps,
        "camera_motion": camera_motion,
        "generate_audio": False,
    }, out_path)

def frame_to_data_uri(frame_bgr, quality=95):
    """Encode a cv2 BGR frame as a base64 JPEG data URI."""
    ok, buf = cv2.imencode(".jpg", frame_bgr, [int(cv2.IMWRITE_JPEG_QUALITY), quality])
    if not ok:
        raise RuntimeError("JPEG encoding failed")
    b64 = base64.b64encode(buf.tobytes()).decode("ascii")
    return f"data:image/jpeg;base64,{b64}"
