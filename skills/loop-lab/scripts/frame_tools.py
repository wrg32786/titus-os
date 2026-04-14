"""
Frame extraction, SSIM measurement, and encoding utilities for loop-lab.
"""
import cv2
import numpy as np
from skimage.metrics import structural_similarity as ssim


def read_endpoint(path, which="first"):
    """Read the first or last decodable frame from a video file.
    Returns a BGR numpy array.
    """
    cap = cv2.VideoCapture(path)
    if not cap.isOpened():
        raise RuntimeError(f"Could not open video: {path}")
    total = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))

    if which == "first":
        cap.set(cv2.CAP_PROP_POS_FRAMES, 0)
        ok, frame = cap.read()
        cap.release()
        if not ok:
            raise RuntimeError(f"Failed to read first frame from {path}")
        return frame

    # Last frame — iterate backward to find last decodable
    for idx in range(total - 1, max(-1, total - 10), -1):
        cap.set(cv2.CAP_PROP_POS_FRAMES, idx)
        ok, frame = cap.read()
        if ok and frame is not None:
            cap.release()
            return frame
    cap.release()
    raise RuntimeError(f"Failed to read last frame from {path}")


def compute_ssim(a, b):
    """Compute SSIM between two BGR frames. Returns float 0-1."""
    if a.shape != b.shape:
        h = min(a.shape[0], b.shape[0])
        w = min(a.shape[1], b.shape[1])
        a = cv2.resize(a, (w, h))
        b = cv2.resize(b, (w, h))
    gray_a = cv2.cvtColor(a, cv2.COLOR_BGR2GRAY)
    gray_b = cv2.cvtColor(b, cv2.COLOR_BGR2GRAY)
    return float(ssim(gray_a, gray_b, data_range=255))


def compute_mse(a, b):
    """Compute mean squared error between two BGR frames."""
    if a.shape != b.shape:
        h = min(a.shape[0], b.shape[0])
        w = min(a.shape[1], b.shape[1])
        a = cv2.resize(a, (w, h))
        b = cv2.resize(b, (w, h))
    return float(np.mean((a.astype(np.float32) - b.astype(np.float32)) ** 2))


def pixel_diff_pct(a, b, threshold=10):
    """Fraction of pixels differing by more than threshold in any channel."""
    if a.shape != b.shape:
        h = min(a.shape[0], b.shape[0])
        w = min(a.shape[1], b.shape[1])
        a = cv2.resize(a, (w, h))
        b = cv2.resize(b, (w, h))
    diff = np.abs(a.astype(np.int16) - b.astype(np.int16))
    return float(np.mean(np.any(diff > threshold, axis=2)) * 100)
