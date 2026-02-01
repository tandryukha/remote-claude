# Remote Claude - Self-Hosted Mobile Access

Access Claude Code sessions from your phone at the gym. Fully self-hosted for security.

## Quick Start

```bash
# Terminal 1: Start everything
happy-start

# Terminal 2: Start Claude session
calorie    # or: dropship
```

That's it! `happy-start` launches the server, web UI, and tunnels. Open the URL on your phone.

### First Time Setup
1. Open the tunnel URL in your browser (copied to clipboard)
2. Click "Create account" to create a local account
3. Run `calorie` or `dropship` in another terminal
4. When prompted for auth, select "Web Browser" - it will open your local web UI
5. Approve the connection

---

## Commands

| Command | Description |
|---------|-------------|
| **Main** | |
| `happy-start` | Start everything (server + tunnels + web UI) |
| `happy-shutdown` | Stop everything |
| **Claude Sessions** | |
| `calorie` | Start Claude in calorie-slo with --dangerously-skip-permissions |
| `dropship` | Start Claude in dropshipping-irondust with --dangerously-skip-permissions |
| **Happy (Manual)** | |
| `happy-web [API_URL]` | Start web UI (pass tunneled API URL for mobile) |
| `tunnel-happy-api` | Expose Happy Server API (port 3005) |
| `tunnel-happy-web` | Expose Happy Web UI (port 8081) |
| **App Testing** | |
| `tunnel <port> <name>` | Create a tunnel to any local port |
| `tunnel-calorie` | Expose localhost:3000 for mobile testing |
| `tunnel-dropship` | Expose localhost:5173 for mobile testing |
| **Shutdown** | |
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
| Happy Web | 8081 | Web UI (Expo) |
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

# If database tables missing, rebuild with migrations
cd ~/happy-server && docker-compose down && docker-compose build --no-cache && docker-compose up -d
```

## Initial Setup (one-time)

The happy-server Dockerfile needs a fix to include prisma migrations. After cloning:

```bash
# 1. Clone repos
git clone https://github.com/slopus/happy-server ~/happy-server
git clone https://github.com/slopus/happy ~/happy

# 2. Copy docker-compose.yml from this repo
cp ~/remote-claude/config/docker-compose.yml ~/happy-server/

# 3. Patch Dockerfile to include prisma and migrations
# (see config/Dockerfile.patch)

# 4. Build and start
cd ~/happy-server && docker-compose up -d
```

---

## Environment Variables

The scripts automatically set these for self-hosted operation:

| Variable | Purpose |
|----------|---------|
| `HAPPY_SERVER_URL` | API server URL (localhost:3005) |
| `HAPPY_WEBAPP_URL` | Web UI URL for CLI auth (tunneled URL) |
| `EXPO_PUBLIC_SERVER_URL` | API URL for web UI (tunneled URL) |

Tunnel URLs are saved to `/tmp/happy-api-url` and `/tmp/happy-web-url` for scripts to read.

---

## Note on Quick Tunnels

URLs like `https://random-words.trycloudflare.com` change on each restart. For persistent URLs, transfer your domain's DNS to Cloudflare (free).
