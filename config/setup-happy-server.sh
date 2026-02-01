#!/bin/bash
# Setup Happy Server with proper configuration
# Run this once after cloning the repos

set -e

echo "Setting up Happy Server..."

# Check if repos exist
if [ ! -d ~/happy-server ]; then
    echo "Cloning happy-server..."
    git clone https://github.com/slopus/happy-server ~/happy-server
fi

if [ ! -d ~/happy ]; then
    echo "Cloning happy..."
    git clone https://github.com/slopus/happy ~/happy
    cd ~/happy && yarn install
fi

# Copy docker-compose.yml
echo "Copying docker-compose.yml..."
cp "$(dirname "$0")/docker-compose.yml" ~/happy-server/

# Patch Dockerfile to include prisma and run migrations
echo "Patching Dockerfile..."
cd ~/happy-server

# Add prisma copy and entrypoint if not already patched
if ! grep -q "COPY --from=builder /app/prisma" Dockerfile; then
    sed -i '' 's|COPY --from=builder /app/sources ./sources|COPY --from=builder /app/sources ./sources\nCOPY --from=builder /app/prisma ./prisma\n\n# Run database migrations on startup\nRUN echo '"'"'#!/bin/sh\\nnpx prisma migrate deploy\\nyarn start'"'"' > /app/entrypoint.sh \&\& chmod +x /app/entrypoint.sh|' Dockerfile
    sed -i '' 's|CMD \["yarn", "start"\]|CMD ["/app/entrypoint.sh"]|' Dockerfile
fi

# Build and start
echo "Building and starting Happy Server..."
docker-compose build
docker-compose up -d

echo ""
echo "Waiting for server to start..."
sleep 10

if curl -s http://localhost:3005/health | grep -q "ok"; then
    echo "✅ Happy Server is running!"
else
    echo "❌ Server failed to start. Check logs with: docker-compose logs happy-server"
fi
