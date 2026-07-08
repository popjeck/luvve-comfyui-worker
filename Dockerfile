# Base worker-comfyui image.
# 5.8.6-base-cuda12.8.1: CUDA 12.8 adds Blackwell (sm_120) support for RTX PRO 6000.
# The older 5.1.0-base lacked it -> "CUDA error: no kernel image available".
FROM runpod/worker-comfyui:5.8.6-base-cuda12.8.1

# ROOT CAUSE of the "UltralyticsDetectorProvider not found" failures:
# ComfyUI runs from the /opt/venv environment on this base image (confirmed in the
# worker startup log: web root under /opt/venv/.../site-packages).
# But comfy-node-install (ComfyUI-Manager, via uv) installs node requirements into a
# SEPARATE venv at /comfyui/.venv - NOT into /opt/venv. So at runtime Impact-Pack and
# Impact-Subpack failed to import ("No module named 'skimage'" / "No module named 'dill'"),
# and because UltralyticsDetectorProvider lives in the subpack, the node never registered.
#
# Fix: install the runtime deps EXPLICITLY into /opt/venv so the ComfyUI process can
# import them. This covers the full Impact-Pack + Impact-Subpack + controlnet_aux dep set.
RUN /opt/venv/bin/pip install --no-cache-dir \
      opencv-python-headless \
      ultralytics \
      scikit-image \
      dill \
      segment-anything \
      piexif \
      matplotlib \
      scipy

# Fail the build immediately if any import-gating dep is missing from the RUNTIME venv,
# instead of discovering it at runtime on the serverless endpoint.
RUN /opt/venv/bin/python -c "import cv2, ultralytics, skimage, dill, segment_anything; print('runtime deps ok, ultralytics', ultralytics.__version__)"

# Install the custom nodes themselves (clone from the ComfyUI registry).
# Their Python deps are already satisfied in /opt/venv by the step above.
#   rgthree-comfy          -> Power Lora Loader (106...), Image Comparer
#   comfyui-impact-pack    -> Bbox/Segm DetectorSEGS, MaskToSEGS, SAMDetector, SAMLoader, DetailerForEachDebug
#   comfyui-impact-subpack -> UltralyticsDetectorProvider, MediaPipeFaceMeshToSEGS
#   comfyui_controlnet_aux -> MediaPipe-FaceMeshPreprocessor (node 474)
RUN comfy-node-install \
      rgthree-comfy \
      comfyui-impact-pack \
      comfyui-impact-subpack \
      comfyui_controlnet_aux

# Tell ComfyUI to also read models from the network volume (/runpod-volume).
# ComfyUI auto-loads extra_model_paths.yaml from its base dir (/comfyui) at startup.
COPY extra_model_paths.yaml /comfyui/extra_model_paths.yaml
