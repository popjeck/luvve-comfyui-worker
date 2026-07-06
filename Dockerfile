# Base worker-comfyui image (ComfyUI + serverless handler already inside).
FROM runpod/worker-comfyui:5.1.0-base

RUN comfy-node-install \
      rgthree-comfy \
      comfyui-impact-pack \
      comfyui-impact-subpack \
      comfyui_controlnet_aux

# Symlink volume models into ComfyUI's internal dirs at startup, then run worker.
COPY start_luvve.sh /start_luvve.sh
RUN chmod +x /start_luvve.sh
CMD ["/start_luvve.sh"]
