---
type: decisions_registry
entry_prefix: BDR
schema:
  id: BDR-XXX
  date: YYYY-MM-DD
  title: string (<= 80 chars)
  decision: string (what was chosen)
  why: string (motivation, context)
  alternatives: list of strings (what was rejected + why)
  status: [proposed | accepted | deprecated | superseded]
  supersedes: BDR-XXX (optional)
rules:
  - Append-only. Never rewrite past entries - add a new one with status superseded if needed.
  - One entry per non-trivial choice. Trivial = reversible in under 10 min with no cross-file impact.
  - Capture why more carefully than what - the what rots, the why lasts.
---

# Decisions registry (BDR)

## Index

| ID | Date | Title | Status |
|----|------|-------|--------|
| BDR-001 | 2026-05-15 | Static single-file site, no framework | accepted |
| BDR-002 | 2026-05-15 | weasyprint pour PDF CV depuis HTML | accepted |
| BDR-003 | 2026-05-15 | Position pro: CDI prioritaire, freelance parallèle | accepted |
| BDR-004 | 2026-05-15 | Containerize site with nginx:alpine behind reverse proxy | accepted |

---

## BDR-001 — Static single-file site, no framework

- **Date**: 2026-05-15
- **Statut**: accepted
- **Décision**: `index.html` unique, CSS inline `<style>`, JS vanilla inline `<script>`. Aucun bundler, aucun build step.
- **Pourquoi**: Landing perso 1 page. Audience recruteurs/CTO. Critère "click Contacter <10s". Zéro dep, zéro maintenance, zéro tracking. Indexable par défaut.
- **Alternatives rejetées**:
  - Astro — overkill, ajoute build step pour 1 page.
  - React SPA — interdit pour site public indexable (cf `~/.claude/CLAUDE.md`).
  - HTML + CSS externes — éclate 1 livrable en 3 fichiers sans bénéfice.
- **Référence**: `index.html`, section Stack de `CLAUDE.md`.

---

## BDR-002 — `weasyprint` pour génération PDF CV

- **Date**: 2026-05-15
- **Statut**: accepted
- **Décision**: `weasyprint CV_Bastien_Chanot.html CV_Bastien_Chanot.pdf` à chaque modif HTML CV.
- **Pourquoi**: weasyprint déjà installé (`~/.local/bin/weasyprint`). Chromium absent. wkhtmltopdf déprécié.
- **Alternatives rejetées**:
  - Chromium `--print-to-pdf` — pas installé.
  - wkhtmltopdf — déprécié + WebKit ancien, rendu moins fidèle.
  - Print manuel via navigateur — pas reproductible, dérive entre HTML et PDF.
- **Warnings connus**: `box-shadow: none` ignoré par weasyprint, sans impact visuel.
- **Référence**: `CV_Bastien_Chanot.pdf`.

---

## BDR-003 — Position pro: CDI prioritaire, missions freelance en parallèle

- **Date**: 2026-05-15
- **Statut**: accepted
- **Décision**: Site annonce **CDI systèmes/embarqué prioritaire**, ZenQuality (freelance) en parallèle. Géo: full remote idéal, hybride 1-2 j/mois si Paris, mobilité Pays de la Loire.
- **Pourquoi**: Recadrage user. Première version annonçait "Missions long terme & expertise" — pas représentatif. Hiérarchie CDI > freelance maintenant explicite (hero eyebrow + about para + callout + CV header).
- **Référence**: `index.html` (hero-eyebrow, about-text para 3, about-callout) + `CV_Bastien_Chanot.html` (header).

---

## BDR-004 — Containerize site with nginx:alpine behind reverse proxy

- **Date**: 2026-05-15
- **Status**: accepted
- **Decision**: Ship site as `bchanot-web` Docker container (`nginx:1.27-alpine`). Container listens on port 80 internally; host port configurable via `PORT` env (default 8080), bound to `127.0.0.1`. Host nginx terminates TLS + `proxy_pass` to container.
- **Why**: VPS hosts multiple sites (`zenquality.fr`, `nuit-folle.zenquality.fr`, `bchanot.fr`). Container isolates static assets + nginx config, easier rollback, reproducible build. Loopback bind blocks direct external hits, forces traffic through host nginx (TLS, rate limit, logs).
- **Hardening**: `read_only: true`, `cap_drop: ALL` + minimal `cap_add`, `no-new-privileges`, tmpfs for `/var/cache/nginx` + `/var/run` + `/tmp`. CSP allows inline CSS/JS (project convention) + Google Fonts. HSTS deliberately omitted at container level — set by outer proxy after TLS termination.
- **Alternatives rejected**:
  - Bare static files served by host nginx — no isolation, config drift between sites, harder rollback.
  - Caddy / Traefik container — overkill for 1 static site, host nginx already handles TLS for other domains.
- **Reference**: `Dockerfile`, `nginx.conf`, `docker-compose.yml`, `.env.example`.
