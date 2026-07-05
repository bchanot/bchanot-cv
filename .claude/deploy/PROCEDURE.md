#!/usr/bin/env bash
# === deploy runbook (reference) — NOT run directly. Instantiated to NEXT.sh per delta. ===
# Fixed steps run every deploy; # @delta: steps re-instantiate from the delta.
# @config push_deploy_tags=false
# Static site baked into the nginx image (COPY whitelist): any content or
# infra change needs a rebuild; docs/.claude-only deltas skip it.
# Front: VPS native nginx (TLS, HSTS) → proxy_pass 127.0.0.1:$PORT → container.
# Style: one command per line, as typed in an interactive session — step 1 opens
# the ssh session, later steps run ON the box; local steps say "(from your machine)".

# 1) connect + pull the desired branch (fixed)
ssh "$DEPLOY_HOST"
cd "$APP_DIR"
git pull                                # VERIFY: HEAD == target sha

# @delta:rebuild when=index.html,CV_Bastien_Chanot.*,favicon*,apple-touch-icon.png,Dockerfile,docker-compose*.yml,nginx*.conf
# 2) rebuild + restart the container (content is baked into the image)
docker compose up -d --build            # VERIFY: docker compose ps → healthy

# 3) smoke test (from your machine)
curl -fsS -o /dev/null -w '%{http_code}\n' https://bchanot.fr/       # VERIFY: 200
curl -sI https://bchanot.fr/ | grep -i 'x-content-type-options'      # VERIFY: nosniff
# ROLLBACK: on the VPS — git checkout deploy/<date-précédent> && docker compose up -d --build
