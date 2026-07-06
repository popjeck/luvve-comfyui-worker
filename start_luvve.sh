#!/usr/bin/env bash
# Link models from the network volume into ComfyUI's internal model dirs,
# then hand off to the base worker-comfyui entrypoint.
set -e

VOL="/runpod-volume/ComfyUI/models"
DST="/comfyui/models"

for sub in checkpoints loras vae ultralytics ultralytics/bbox ultralytics/segm sams embeddings controlnet upscale_models; do
  if [ -d "$VOL/$sub" ]; then
    mkdir -p "$DST/$sub"
    # symlink each file from volume subdir into the matching internal subdir
    for f in "$VOL/$sub"/*; do
      [ -e "$f" ] || continue
      ln -sf "$f" "$DST/$sub/$(basename "$f")"
    done
  fi
done

# Hand off to the original worker entrypoint.
exec /start.sh
