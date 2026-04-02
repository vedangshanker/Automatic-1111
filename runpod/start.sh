#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/opt/stable-diffusion-webui"
DATA_DIR="${A1111_DATA_DIR:-/workspace}"
MODELS_DIR="${A1111_MODELS_DIR:-$DATA_DIR/models}"
SEED_DIR="/opt/webui-seed"
PYTHON_BIN="${VIRTUAL_ENV:-/opt/venv}/bin/python"

copy_if_missing() {
    local src="$1"
    local dst="$2"

    if [[ ! -e "$dst" && -e "$src" ]]; then
        mkdir -p "$(dirname "$dst")"
        cp -a "$src" "$dst"
    fi
}

copy_dir_if_missing() {
    local src="$1"
    local dst="$2"

    if [[ ! -d "$dst" && -d "$src" ]]; then
        mkdir -p "$(dirname "$dst")"
        cp -a "$src" "$dst"
    fi
}

mkdir -p \
    "$DATA_DIR" \
    "$MODELS_DIR" \
    "$DATA_DIR/outputs" \
    "$DATA_DIR/embeddings" \
    "$DATA_DIR/extensions" \
    "$DATA_DIR/cache"

copy_if_missing "$SEED_DIR/config.seed.json" "$DATA_DIR/config.json"
copy_if_missing "$SEED_DIR/ui-config.seed.json" "$DATA_DIR/ui-config.json"
copy_dir_if_missing "$SEED_DIR/extensions/sd-webui-civbrowser" "$DATA_DIR/extensions/sd-webui-civbrowser"
copy_dir_if_missing "$SEED_DIR/extensions/sd_civitai_extension" "$DATA_DIR/extensions/sd_civitai_extension"

export STABLE_DIFFUSION_REPO="${STABLE_DIFFUSION_REPO:-https://github.com/w-e-w/stablediffusion.git}"
export PYTORCH_CUDA_ALLOC_CONF="${PYTORCH_CUDA_ALLOC_CONF:-expandable_segments:True}"

ARGS=(
    --listen
    --port "${A1111_PORT:-7860}"
    --api
    --enable-insecure-extension-access
    --skip-python-version-check
    --no-download-sd-model
    --data-dir "$DATA_DIR"
    --models-dir "$MODELS_DIR"
    --ui-settings-file "$DATA_DIR/config.json"
    --ui-config-file "$DATA_DIR/ui-config.json"
)

if [[ "${A1111_ENABLE_XFORMERS:-0}" == "1" ]]; then
    ARGS+=(--xformers)
fi

if [[ -n "${A1111_EXTRA_ARGS:-}" ]]; then
    # shellcheck disable=SC2206
    EXTRA_ARGS=( ${A1111_EXTRA_ARGS} )
    ARGS+=("${EXTRA_ARGS[@]}")
fi

cd "$APP_DIR"
exec "$PYTHON_BIN" launch.py "${ARGS[@]}"

