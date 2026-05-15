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

Static files — drop `index.html`, `CV_Bastien_Chanot.html`, and
`CV_Bastien_Chanot.pdf` onto any static host (Netlify, Vercel, GitHub Pages,
plain nginx) at the root.

## License

Personal site content — © Bastien Chanot.
