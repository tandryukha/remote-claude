# Remote Claude - Self-Hosted Mobile Access

Access Claude Code sessions from your phone at the gym. Fully self-hosted for security.

## Quick Start

```bash
# Reload shell config
source ~/.zshrc

# Start a tunnel for the Happy Server
tunnel 3005 happy-api    # Copy the URL that appears

# In another terminal, start Claude in your project
calorie                  # or: dropship
```

Scan the QR code from your phone to connect.

---

## Commands

| Command | Description |
|---------|-------------|
| `calorie` | Start Claude in calorie-slo with --dangerously-skip-permissions |
| `dropship` | Start Claude in dropshipping-irondust with --dangerously-skip-permissions |
| `tunnel <port> <name>` | Create a tunnel to any local port |
| `tunnel-calorie` | Expose localhost:3000 for mobile testing |
| `tunnel-dropship` | Expose localhost:5173 for mobile testing |
| `happy-web` | Start the self-hosted web UI |
| `happy-stop` | Stop all happy processes |
| `tunnel-stop` | Stop all tunnels |
| `happy-shutdown` | Stop everything |

---

## Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────┐
│   Your Phone    │────▶│ Cloudflare Tunnel │────▶│ Happy Server│
│   (at gym)      │     │ (Quick Tunnel)    │     │ (localhost) │
└─────────────────┘     └──────────────────┘     └─────────────┘
                                                        │
                                                        ▼
                                                 ┌─────────────┐
                                                 │ Claude Code │
                                                 │  Session    │
                                                 └─────────────┘
```

All components run on your machine. End-to-end encrypted.

---

## Services

| Service | Port | Purpose |
|---------|------|---------|
| Happy Server | 3005 | API relay (Docker) |
| Happy Web | 3006 | Web UI (optional) |
| PostgreSQL | 5432 | Database (Docker) |
| Redis | 6379 | Cache (Docker) |
| MinIO | 9000 | File storage (Docker) |

---

## File Locations

```
~/remote-claude/scripts/  # All scripts (this project)
~/happy-server/           # Backend (Docker)
~/happy/                  # Monorepo with web app
~/.zshrc                  # Adds scripts to PATH
```

---

## Troubleshooting

```bash
# Check if Happy Server is running
curl http://localhost:3005/health

# View server logs
cd ~/happy-server && docker-compose logs -f happy-server

# Restart everything
cd ~/happy-server && docker-compose down && docker-compose up -d
```

---

## Note on Quick Tunnels

URLs like `https://random-words.trycloudflare.com` change on each restart. For persistent URLs, transfer your domain's DNS to Cloudflare (free).
