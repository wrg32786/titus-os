"""
Custom full-resolution inference wrapper for Practical-RIFE v4.25.
Generates N intermediate frames between two keyframes without downscaling.

Usage: python prife_interp.py img0.png img1.png out_dir N
"""
import sys, os, cv2, torch
import torch.nn.functional as F

PR = r"C:\Users\willg\Downloads\Practical-RIFE"
sys.path.insert(0, PR)
os.chdir(PR)

from train_log.RIFE_HDv3 import Model

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
torch.set_grad_enabled(False)

model = Model()
model.load_model("train_log", -1)
model.eval()
model.device()
print(f"RIFE v{model.version} loaded on {device}")

def load_img(path):
    img = cv2.imread(path, cv2.IMREAD_UNCHANGED)
    return (torch.tensor(img.transpose(2,0,1)).to(device) / 255.).unsqueeze(0), img.shape

def pad(t, h, w):
    ph = ((h - 1) // 64 + 1) * 64
    pw = ((w - 1) // 64 + 1) * 64
    return F.pad(t, (0, pw - w, 0, ph - h)), ph, pw

def save_img(tensor, path, h, w):
    out = (tensor[0] * 255.).byte().cpu().numpy().transpose(1,2,0)
    out = out[:h, :w]
    cv2.imwrite(path, out)

img0_path, img1_path, out_dir, n_interp = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4])
os.makedirs(out_dir, exist_ok=True)

img0, (h, w, _) = load_img(img0_path)
img1, _         = load_img(img1_path)
img0_p, _, _    = pad(img0, h, w)
img1_p, _, _    = pad(img1, h, w)

N = n_interp
print(f"Generating {N} intermediate frames at {w}x{h}...")
for i in range(1, N + 1):
    t = i / (N + 1)
    mid = model.inference(img0_p, img1_p, t)
    out_path = os.path.join(out_dir, f"{i:04d}.png")
    save_img(mid, out_path, h, w)
    print(f"  frame {i}/{N}  (t={t:.3f}) -> {out_path}")
print("Done.")
