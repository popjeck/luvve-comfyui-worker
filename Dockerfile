# Base worker-comfyui image.
# 5.8.6-base-cuda12.8.1: CUDA 12.8 adds Blackwell (sm_120) support for RTX PRO 6000.
# The older 5.1.0-base lacked it -> "CUDA error: no kernel image available".
FROM runpod/worker-comfyui:5.8.6-base-cuda12.8.1

# Runtime deps that Impact-Subpack imports at ComfyUI startup.
# If ANY of these is missing, UltralyticsDetectorProvider silently fails to
# register and the workflow dies with "Node 'UltralyticsDetectorProvider' not found".
#   - opencv-python-headless: cv2, server-safe build (no GUI/X11 deps).
#   - ultralytics: required by UltralyticsDetectorProvider (YOLO). On SERVERLESS
#     the worker has no internet at runtime, so Impact-Subpack cannot auto-install
#     it on first start - it MUST be baked into the image here at build time.
RUN pip install --no-cache-dir \
      opencv-python-headless \
      ultralytics

# Fail the build immediately if the import-gating deps are not present,
# instead of discovering it at runtime on the serverless endpoint.
RUN python -c "import cv2, ultralytics; print('deps ok, ultralytics', ultralytics.__version__)"

# Install every custom node the workflow requires, together with their Python deps.
# comfy-node-install pulls each node from the ComfyUI registry and runs its requirements.
# Derived from a full parse of workflow_api.json (59 nodes):
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
