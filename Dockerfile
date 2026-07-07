# Base worker-comfyui image.
# 5.8.6-base-cuda12.8.1: CUDA 12.8 adds Blackwell (sm_120) support for RTX PRO 6000.
# The older 5.1.0-base lacked it -> "CUDA error: no kernel image available".
FROM runpod/worker-comfyui:5.8.6-base-cuda12.8.1

# Impact-Subpack imports cv2 (OpenCV), which is not present in this base image.
# Without it the subpack fails to load and UltralyticsDetectorProvider goes missing.
# opencv-python-headless is the server-safe build (no GUI/X11 deps).
RUN pip install --no-cache-dir opencv-python-headless

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
