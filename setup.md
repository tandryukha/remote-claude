# Happy Server Self-Hosting Guide
> Claude Code mobile access via Cloudflare Tunnel — no public IP required

---

## Prerequisites

- Docker + Docker Compose installed
- A domain you control (e.g., `yourdomain.com`)
- Cloudflare account (free tier works)
- Domain DNS managed by Cloudflare

---

## 1. Clone & Configure Server

```bash
# Clone the server
git clone https://github.com/slopus/happy-server
cd happy-server

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  happy-server:
    build: .
    ports:
      - "3005:3005"
    environment:
      - NODE_ENV=production
      - PORT=3005
      - DATABASE_URL=postgresql://postgres:postgres@postgres:5432/happy
      - REDIS_URL=redis://redis:6379
      - SEED=CHANGE_ME_TO_RANDOM_64_CHAR_STRING
    depends_on:
      - postgres
      - redis
    restart: unless-stopped

  postgres:
    image: postgres:15-alpine
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=happy
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
EOF

# Generate a secure SEED (replace in docker-compose.yml)
openssl rand -hex 32
```

**⚠️ Replace `SEED=CHANGE_ME_TO_RANDOM_64_CHAR_STRING` with output from openssl command**

---

## 2. Start the Server

```bash
docker-compose up -d

# Verify it's running
curl http://localhost:3005/health
# Should return: OK or {"status":"ok"}
```

---

## 3. Setup Cloudflare Tunnel

```bash
# Install cloudflared
# macOS
brew install cloudflare/cloudflare/cloudflared

# Ubuntu/Debian
curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | sudo tee /usr/share/keyrings/cloudflare-main.gpg
echo 'deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared jammy main' | sudo tee /etc/apt/sources.list.d/cloudflared.list
sudo apt update && sudo apt install cloudflared

# Login to Cloudflare
cloudflared tunnel login
# Opens browser — select your domain

# Create tunnel
cloudflared tunnel create happy-tunnel

# Note the tunnel ID output (e.g., a]1234abcd-5678-...)
```

---

## 4. Configure Tunnel

```bash
# Create config file
mkdir -p ~/.cloudflared

cat > ~/.cloudflared/config.yml << 'EOF'
tunnel: YOUR_TUNNEL_ID
credentials-file: /home/YOUR_USER/.cloudflared/YOUR_TUNNEL_ID.json

ingress:
  - hostname: happy-api.yourdomain.com
    service: http://localhost:3005
  - hostname: happy.yourdomain.com
    service: http://localhost:3006
  - service: http_status:404
EOF
```

**Replace:**
- `YOUR_TUNNEL_ID` — from step 3
- `YOUR_USER` — your username
- `yourdomain.com` — your actual domain

---

## 5. Create DNS Records

```bash
# API endpoint
cloudflared tunnel route dns happy-tunnel happy-api.yourdomain.com

# Web app (if hosting UI)
cloudflared tunnel route dns happy-tunnel happy.yourdomain.com
```

---

## 6. (Optional) Host Web App

```bash
# Clone the web app
git clone https://github.com/slopus/happy
cd happy/apps/web

# Install dependencies
npm install

# Build with your server URL
cat > .env.local << 'EOF'
NEXT_PUBLIC_API_URL=https://happy-api.yourdomain.com
EOF

npm run build

# Serve it (or use nginx/caddy)
npm install -g serve
serve -s out -l 3006
```

---

## 7. Run Tunnel as Service

```bash
# Start tunnel (foreground for testing)
cloudflared tunnel run happy-tunnel

# Install as system service (runs on boot)
sudo cloudflared service install
sudo systemctl enable cloudflared
sudo systemctl start cloudflared
```

---

## 8. Configure CLI on Your Machine

```bash
# Add to ~/.bashrc or ~/.zshrc
export HAPPY_SERVER_URL="https://happy-api.yourdomain.com"
export HAPPY_WEBAPP_URL="https://happy.yourdomain.com"

# Reload
source ~/.bashrc

# Test it
happy
```

---

## 9. Access from Phone

Open in mobile browser:
```
https://happy.yourdomain.com
```

Scan QR code from CLI to pair.

---

## Quick Reference

| Component | URL |
|-----------|-----|
| API Server | `https://happy-api.yourdomain.com` |
| Web App | `https://happy.yourdomain.com` |
| Health Check | `https://happy-api.yourdomain.com/health` |

---

## Troubleshooting

```bash
# Check server logs
docker-compose logs -f happy-server

# Check tunnel status
cloudflared tunnel info happy-tunnel

# Test local connectivity
curl http://localhost:3005/health

# Test public connectivity
curl https://happy-api.yourdomain.com/health
```

---

## Run with YOLO Mode

```bash
# Alias for gym sessions
alias happyd='happy --claude-arg "--dangerously-skip-permissions"'
```

---

## Security Notes

- HTTPS is automatic via Cloudflare
- E2E encryption means server only sees encrypted blobs
- SEED should be kept secret — it's used for token generation
- Consider Cloudflare Access for additional auth layer (optional)