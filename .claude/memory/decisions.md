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
| BDR-005 | 2026-05-17 | Favicon: SVG primary + PIL raster fallback | accepted |
| BDR-006 | 2026-07-05 | Hardened container: nginx-unprivileged + port 8080 | accepted (supersedes BDR-004 infra detail) |
| BDR-007 | 2026-07-05 | Profile geo canonical: Nantes relocation | accepted (supersedes BDR-003 geo) |

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

---

## BDR-005 — Favicon: SVG primary + PIL raster fallback

- **Date**: 2026-05-17
- **Status**: accepted
- **Decision**: Ship `favicon.svg` (vector primary) + PIL-generated `favicon-32.png`, `favicon.ico` (16/24/32/48), `apple-touch-icon.png` (180×180). 4 `<link>` tags in `<head>` of `index.html`.
- **Why**: Modern browsers fetch SVG (sharp any DPI). Legacy + iOS fall back ICO/PNG. PIL preinstalled on host → zero new dep. Mark replicates `.brand::before` pulse-dot (visual continuity with nav).
- **Alternatives rejected**:
  - `rsvg-convert` / `inkscape` for SVG→PNG — not installed on host, setup friction.
  - SVG-only — drops Safari <14 + iOS home-screen.
  - Online favicon generator — external dep, opaque rendering, no source control.
- **CV HTML**: not modified (user's WIP M state). Browser auto-fetches `/favicon.ico` from root → CV tab still shows icon. Link block mirror logged in `.claude/tasks/TODO.md` for later.
- **Reference**: `favicon.svg`, `favicon-32.png`, `favicon.ico`, `apple-touch-icon.png`, `index.html` head, commit `ef31fb3`.

---

## BDR-006 — Hardened container: nginx-unprivileged base + port 8080

- **Date**: 2026-07-05
- **Status**: accepted — supersedes the base-image/port detail of BDR-004
- **Decision**: Container base = `nginxinc/nginx-unprivileged:1.28-alpine` (digest-pinned), runs as uid 101, listens on **8080** (not 80). Compose maps `127.0.0.1:${PORT}:8080`; `USER root` scoped to the one build-time `rm` only; `cap_add` dropped; `server_tokens off`; `set_real_ip_from 127.0.0.1`; `nginx-security-headers.conf` re-included per `location`; CSP `script-src` hash-pinned.
- **Why**: SEC-1 tour finding — stock `nginx:*-alpine` runs its master as root inside the container. Unprivileged image + port 8080 removes the root master; the rest shrinks blast radius. BDR-004's "port 80 / nginx:1.27-alpine / HSTS omitted at container" no longer matched the tree.
- **Supersedes**: BDR-004 — topology unchanged (native front proxy → container on loopback); only the base image, internal port, and uid change.
- **Reference**: `Dockerfile`, `docker-compose.yml`, `nginx.conf`, `nginx-security-headers.conf`. Fix commit `ba13d69`; drift caught by tour REC-1 (`.claude/audits/TOUR.md`, run 2026-07-05-2).

---

## BDR-007 — Profile geo canonical: Nantes relocation

- **Date**: 2026-07-05
- **Status**: accepted — supersedes the geography detail of BDR-003
- **Decision**: Canonical profile geo = "Yerres (91) now; installation région nantaise prévue à moyen terme; full remote, hybride possible sur Nantes, ou 1–2 j/mois Paris." CV was the source of truth; `index.html` + `CLAUDE.md` aligned to it.
- **Why**: tour CLN-9 found the landing ("mobilité Pays de la Loire") drifting from the CV ("installation région nantaise" + "hybride Nantes"). Owner chose the CV wording as truth — more current/specific, and Nantes ∈ Pays de la Loire so not contradictory. Cross-file profile-state consistency is a CLAUDE.md content rule.
- **Alternatives rejected**: align CV down to the landing (would delete real, more-specific relocation info).
- **Reference**: `index.html` (about para + about-callout), `CV_Bastien_Chanot.html`, `CLAUDE.md` geography note. Commit `f515875`.
