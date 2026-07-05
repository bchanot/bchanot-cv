#!/usr/bin/env bash
# === deploy runbook (reference) — NOT run directly. Instantiated to NEXT.sh per delta. ===
# Fixed steps run every deploy; # @delta: steps re-instantiate from the delta.
# @config push_deploy_tags=false
# Static site baked into the nginx image (COPY whitelist): any content or
# infra change needs a rebuild; docs/.claude-only deltas skip it.
# Front: VPS native nginx (TLS, HSTS) → proxy_pass 127.0.0.1:$PORT → container.

# 1) pull the desired branch on the VPS (fixed)
ssh "$DEPLOY_HOST" "cd \$APP_DIR && git pull"        # VERIFY: HEAD == target sha

# @delta:rebuild when=index.html,CV_Bastien_Chanot.*,favicon*,apple-touch-icon.png,Dockerfile,docker-compose*.yml,nginx*.conf
# 2) rebuild + restart the container (content is baked into the image)
ssh "$DEPLOY_HOST" "cd \$APP_DIR && docker compose up -d --build"   # VERIFY: docker compose ps → healthy

# 3) smoke test (fixed)
curl -fsS -o /dev/null -w '%{http_code}\n' https://bchanot.fr/       # VERIFY: 200
curl -sI https://bchanot.fr/ | grep -i 'x-content-type-options'      # VERIFY: nosniff
# ROLLBACK: ssh "$DEPLOY_HOST" "cd \$APP_DIR && git checkout deploy/<date-précédent> && docker compose up -d --build"
