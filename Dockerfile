# Base worker-comfyui image (ComfyUI + serverless handler already inside).
# Check Docker Hub "runpod/worker-comfyui" tags and use the newest X.Y.Z-base.
FROM runpod/worker-comfyui:5.1.0-base

# Install the custom nodes the workflow needs, together with their Python deps.
# comfy-node-install pulls each node from the ComfyUI registry and runs its requirements.
# - rgthree-comfy          -> Power Lora Loader (node 106)
# - comfyui-impact-pack    -> Detailer / SEGS / SAMLoader
# - comfyui-impact-subpack -> Ultralytics detector nodes (pulls the ultralytics pip package)
RUN comfy-node-install \
      rgthree-comfy \
      comfyui-impact-pack \
      comfyui-impact-subpack
