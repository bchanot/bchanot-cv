# bchanot.fr

Personal landing page + CV for Bastien Chanot — developer, systems & backend.

Static single-page site (no framework, no build step). Lives at https://bchanot.fr.

## Contents

| File | Purpose |
|------|---------|
| `index.html`                  | Landing page (inline CSS + JS, single file) |
| `CV_Bastien_Chanot.html`      | CV — web version, linked from landing as "Voir le CV" |
| `CV_Bastien_Chanot.pdf`       | CV — printable, served via "Télécharger PDF" |
| `CLAUDE.md`                   | Project rules for the Claude assistant |
| `.claude/`                    | Memory registries, tasks, audits |
| `Dockerfile`                  | Container image build — copies static assets into nginx |
| `docker-compose.yml`          | Service def — host port, hardening (read-only, cap_drop), tmpfs |
| `nginx.conf`                  | In-container nginx — security headers, CSP, gzip, cache |
| `.env.example`                | Sample env — `PORT` for the host bind |
| `favicon.*`, `apple-touch-icon.png` | Favicon set — SVG primary + ICO/PNG + 180×180 apple-touch |

## Local preview

```bash
python3 -m http.server 8000 --bind 0.0.0.0
```

Then open `http://localhost:8000/` (same machine) or `http://192.168.1.101:8000/`
from any device on the LAN.

If the LAN URL is unreachable, the firewall is likely blocking the port:

```bash
sudo ufw allow 8000/tcp
```

## Regenerate the CV PDF after editing the HTML

```bash
weasyprint CV_Bastien_Chanot.html CV_Bastien_Chanot.pdf
```

Run this every time `CV_Bastien_Chanot.html` is modified so the served PDF
stays in sync.

## Stack

- HTML5 + CSS3 (inline `<style>` in `<head>`)
- Vanilla JS (inline `<script>` before `</body>`)
- Google Fonts: JetBrains Mono, Fraunces, DM Sans
- `weasyprint` for HTML → PDF conversion (CV only)

No bundler. No npm. No runtime dependencies beyond Google Fonts.

## Design rules

Strict palette (non-negotiable):

| Hex       | Role |
|-----------|------|
| `#0d1b12` | Dark forest — nav, dark sections, footer |
| `#1b5e3b` | Green primary — section titles, links on light bg |
| `#2d7a4f` | Green accent — borders, dots, separators |
| `#6ab98a` | Green light — text on dark bg |
| `#dff0e7` | Green tint — pill background |
| `#f5f3ec` | Parchment — page background |

Typography:
- `Fraunces` — display (names, titles)
- `JetBrains Mono` — technical labels, badges, pills, nav, contact
- `DM Sans` — body text

Mobile-first, responsive at 768px + 1200px breakpoints.
WCAG AA contrast. Focus visible. Semantic HTML.

## Deploy

Production runs as a Docker container (`bchanot-web`, `nginx:1.27-alpine`)
behind the host's nginx reverse proxy, which terminates TLS and `proxy_pass`es
to it. The host port is set via `PORT` (default 8080) and bound to `127.0.0.1`,
so all traffic goes through the front proxy.

```bash
cp .env.example .env   # optional: set PORT
docker compose up -d --build
```

`Dockerfile` copies the assets (HTML, PDF, favicons) into the image by an
explicit whitelist — when you add a new top-level asset, add it there too or it
will 404 in production. `nginx.conf` applies the security headers, gzip and
cache rules. The site is also plain static: `index.html`, the CV HTML/PDF and
favicon set drop onto any static host (Netlify, Vercel, GitHub Pages, plain
nginx) at the root.

## License

Personal site content — © Bastien Chanot.
