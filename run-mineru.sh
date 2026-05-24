#!/usr/bin/env bash
# MinerU launcher (Linux) — usage: ./run-mineru.sh api | parse | gradio
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

export HF_HUB_DISABLE_SYMLINKS=1
# VPS CPU-only (no GPU): tránh CUDA + giảm lỗi oneDNN "could not create a primitive"
export MINERU_DEVICE_MODE="${MINERU_DEVICE_MODE:-cpu}"
export CUDA_VISIBLE_DEVICES="${CUDA_VISIBLE_DEVICES:-}"
export OMP_NUM_THREADS="${OMP_NUM_THREADS:-2}"
export MKL_NUM_THREADS="${MKL_NUM_THREADS:-2}"
export OPENBLAS_NUM_THREADS="${OPENBLAS_NUM_THREADS:-2}"
export ATEN_CPU_CAPABILITY="${ATEN_CPU_CAPABILITY:-DEFAULT}"
PY="${ROOT}/.venv/bin/python"

if [[ ! -x "$PY" ]]; then
  echo "Virtual env not found. Run: deploy/setup-mineru.sh" >&2
  exit 1
fi

MODE="${1:-help}"
case "$MODE" in
  parse)
    INPUT="${2:-samples/demo_mineru.pdf}"
    OUT="${3:-output}"
    exec "${ROOT}/.venv/bin/mineru" -p "$INPUT" -o "$OUT" -b pipeline
    ;;
  gradio)
    exec "${ROOT}/.venv/bin/mineru-gradio" -b pipeline
    ;;
  api)
    exec "${ROOT}/.venv/bin/python" "${ROOT}/mineru_api_launcher.py" --host 127.0.0.1 --port 8000
    ;;
  *)
    cat <<'EOF'
MinerU launcher (Linux)
  ./run-mineru.sh api                      - REST API (127.0.0.1:8000)
  ./run-mineru.sh parse [input] [output]   - Parse PDF
  ./run-mineru.sh gradio                   - Web UI
EOF
    ;;
esac
