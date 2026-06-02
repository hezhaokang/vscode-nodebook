#!/bin/bash
set -e

mkdir -p /workspace

jupyter notebook \
  --ip=0.0.0.0 \
  --port=7002 \
  --no-browser \
  --allow-root \
  --NotebookApp.token='' \
  --NotebookApp.password='' \
  --notebook-dir=/workspace &

code-server \
  --bind-addr 0.0.0.0:7001 \
  --auth none \
  /workspace
