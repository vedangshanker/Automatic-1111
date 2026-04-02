#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-/opt/stable-diffusion-webui}"
EXT_DIR="${EXT_DIR:-$APP_DIR/extensions}"
SEED_DIR="${SEED_DIR:-/opt/webui-seed/extensions}"

CIVBROWSER_REPO="https://github.com/SignalFlagZ/sd-webui-civbrowser.git"
CIVBROWSER_COMMIT="4d792de4990cd6e163530189f1a4c1944ec4ccaf"
CIVITAI_LINK_REPO="https://github.com/civitai/sd_civitai_extension.git"
CIVITAI_LINK_COMMIT="115cd9c35b0774c90cb9c397ad60ef6a7dac60de"

clone_at_commit() {
    local repo_url="$1"
    local commit_sha="$2"
    local target_dir="$3"

    rm -rf "$target_dir"
    git clone --filter=blob:none "$repo_url" "$target_dir"
    git -C "$target_dir" fetch --depth 1 origin "$commit_sha"
    git -C "$target_dir" checkout --detach "$commit_sha"
}

mkdir -p "$EXT_DIR" "$SEED_DIR"

clone_at_commit "$CIVBROWSER_REPO" "$CIVBROWSER_COMMIT" "$EXT_DIR/sd-webui-civbrowser"
git -C "$EXT_DIR/sd-webui-civbrowser" apply --ignore-whitespace --whitespace=nowarn "$APP_DIR/runpod/patches/sd-webui-civbrowser.patch"

clone_at_commit "$CIVITAI_LINK_REPO" "$CIVITAI_LINK_COMMIT" "$EXT_DIR/sd_civitai_extension"

rm -rf "$SEED_DIR"
mkdir -p "$SEED_DIR"
cp -a "$EXT_DIR/." "$SEED_DIR/"

