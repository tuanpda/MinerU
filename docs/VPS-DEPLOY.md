# MinerU trên VPS (CPU cũ, không GPU)

## File cần có trong repo

- `run-mineru.sh` — launcher API / parse
- `mineru_api_launcher.py` — tắt MKLDNN (tránh `could not create a primitive`)

## Cập nhật trên VPS

```bash
cd /root/vector/MinerU
git pull
chmod +x run-mineru.sh

# Chỉ khi đổi dependency Python
# sudo MINERU_DIR=/root/vector/MinerU /root/vector/vectorsystem/deploy/setup-mineru.sh

# Cập nhật systemd từ repo vectorsystem
sudo sed -e "s|__DEPLOY_USER__|root|g" \
    -e "s|__MINERU_DIR__|/root/vector/MinerU|g" \
  /root/vector/vectorsystem/deploy/systemd/mineru-api.service \
  | sudo tee /etc/systemd/system/mineru-api.service

sudo systemctl daemon-reload
sudo systemctl restart mineru-api
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8000/docs
```

## Thư viện hệ thống (một lần)

```bash
sudo apt install -y libgl1 libglib2.0-0 libsm6 libxext6 libxrender1 fonts-noto-core fonts-noto-cjk
```

## Không commit

- `.venv/`, `output/`, `.coverage`
