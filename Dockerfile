# Base worker-comfyui image (ComfyUI + serverless handler already inside).
# Check Docker Hub "runpod/worker-comfyui" tags and use the newest X.Y.Z-base.
FROM runpod/worker-comfyui:5.1.0-base
 
# Install every custom node the workflow requires, together with their Python deps.
# comfy-node-install pulls each node from the ComfyUI registry and runs its requirements.
# Derived from a full parse of workflow_api.json (59 nodes, 21 class_types):
#   rgthree-comfy          -> Power Lora Loader (106...), Image Comparer
#   comfyui-impact-pack    -> Bbox/Segm DetectorSEGS, MaskToSEGS, SAMDetector, SAMLoader, DetailerForEachDebug
#   comfyui-impact-subpack -> UltralyticsDetectorProvider, MediaPipeFaceMeshToSEGS
#   comfyui_controlnet_aux -> MediaPipe-FaceMeshPreprocessor (node 474)
RUN comfy-node-install \
      rgthree-comfy \
      comfyui-impact-pack \
      comfyui-impact-subpack \
      comfyui_controlnet_aux
 
