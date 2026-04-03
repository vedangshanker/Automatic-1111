FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    TINI_SUBREAPER=1 \
    VIRTUAL_ENV=/opt/venv \
    PATH=/opt/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    STABLE_DIFFUSION_REPO=https://github.com/w-e-w/stablediffusion.git

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    ffmpeg \
    git \
    libgl1 \
    libglib2.0-0 \
    libgoogle-perftools4 \
    python3 \
    python3-pip \
    python3-venv \
    rsync \
    tini \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv "$VIRTUAL_ENV" && \
    python -m pip install --upgrade pip && \
    python -m pip install "setuptools<82" wheel

RUN useradd --create-home --shell /bin/bash app

WORKDIR /opt/stable-diffusion-webui

COPY . /opt/stable-diffusion-webui

RUN bash runpod/install_extensions.sh

RUN mkdir -p /opt/webui-seed && \
    cp runpod/config.seed.json /opt/webui-seed/config.seed.json && \
    printf "{}\n" > /opt/webui-seed/ui-config.seed.json

RUN python launch.py \
    --skip-python-version-check \
    --skip-torch-cuda-test \
    --no-download-sd-model \
    --exit

RUN rm -rf /root/.cache /tmp/*

EXPOSE 7860

ENTRYPOINT ["/usr/bin/tini", "-s", "--"]
CMD ["bash", "/opt/stable-diffusion-webui/runpod/start.sh"]
