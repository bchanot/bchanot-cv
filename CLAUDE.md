# bchanot.fr — CLAUDE.md

Single source of truth for Claude in this repo.
Global rules: `~/.claude/CLAUDE.md` — this file extends or overrides them.

---

## Project overview

Personal landing page + CV for Bastien Chanot (developer, systems & backend).
Single-page static site served at https://bchanot.fr. Goal: a recruiter or CTO
landing on the page decides whether to contact within 10 seconds.

Audience: technical recruiters, CTOs, engineering managers. Use case: hub for
contact + CV access. No tracking, no analytics, no cookie banner.

---

## Stack

- Pure static HTML/CSS/JS — no framework, no build step.
- Fonts: Google Fonts (`JetBrains Mono` mono, `Fraunces` display, `DM Sans` sans).
- PDF generation for CV: `weasyprint` (from the matching HTML file).

No package manager. No bundler. No runtime dependencies beyond Google Fonts.

---

## Files

```
index.html                  — landing page (single file, inline CSS + JS)
CV_Bastien_Chanot.html      — CV (web version, linked from landing as "Voir le CV")
CV_Bastien_Chanot.pdf       — CV (printable, served via "Télécharger PDF")
README.md                   — repo readme
CLAUDE.md                   — this file
.claude/                    — Claude memory, tasks, audits
```

---

## Serve locally

```bash
python3 -m http.server 8000 --bind 0.0.0.0
# then visit http://192.168.1.101:8000/ from any device on the LAN
```

UFW may block the port — open it on demand only:

```bash
sudo ufw allow 8000/tcp
```

---

## Regenerate CV PDF (after editing the HTML)

```bash
weasyprint CV_Bastien_Chanot.html CV_Bastien_Chanot.pdf
```

The PDF must match the latest HTML before pushing or sending.

---

## Design system (non-negotiable)

Palette — exact hex (brand colors):
- `#0d1b12` — dark forest (nav, dark sections, footer)
- `#1b5e3b` — green primary (links, section titles on light bg)
- `#2d7a4f` — green accent (borders, dots, separators)
- `#6ab98a` — green light (lisible on dark bg)
- `#dff0e7` — green tint (pill bg)
- `#f5f3ec` — parchment (page bg)

Functional neutrals (allowed, intentional — layering + text, NOT brand):
- `#183325` (`--dark-mid`), `#0e3320` (`--g900`), `#eef7f1` (`--g050`) —
  green-scale intermediates for dark layering and light block bg
- `#111111` / `#1e1e1e` / `#636363` (`--ink-1/2/3`) — text hierarchy
- `#d8d4c8` (`--rule`), `#e6e2d8` (`--tag`) — separators, generic tags
- `#ffffff` text + `rgba(255,255,255,…)` alphas — text/hover on dark bg and
  low-alpha (≤5%) overlays only; never as a background color
Any color outside these lists is a violation.

Typography:
- `Fraunces` (serif) — display: hero name, section titles, role headings
- `JetBrains Mono` (mono) — eyebrows, badges, tech pills, nav, contact rows
- `DM Sans` (sans) — body text

CV exception (`CV_Bastien_Chanot.html`, compact print style): section titles
and company/school names are mono, roles/degrees are sans; Fraunces is
reserved for the header name and the accroche. The mapping above applies to
the landing.

Forbidden:
- Pure white background (`#ffffff`)
- `border-radius` > 6px except pills
- Heavy SVG illustrations
- Lorem ipsum or placeholder text
- Mention of salary / TJM / pricing

---

## Project conventions

- All CSS lives inline in `<head>` (`<style>`) — no external stylesheet.
- All JS lives inline before `</body>` (`<script>`) — vanilla only.
- CSS variables in `:root` for palette + typography + spacing scale.
- Section comments in HTML: `<!-- HERO -->`, `<!-- ABOUT -->`, etc.
- Sections semantic: `<header>`, `<main>`, `<section id="…">`, `<footer>`.
- Mobile-first. Breakpoints: 768px (tablet), 1200px (desktop).
- Animations CSS-only or vanilla JS. No GSAP, no Three.js, no Lottie.
- `prefers-reduced-motion: reduce` must disable animation + smooth-scroll.

---

## Content rules

- Only real information — never invent dates, companies, achievements.
- French copy (audience is French market).
- Profile state, including job search context, must stay consistent across
  index.html and CV. Currently: looking for **CDI** in embedded / systems
  software first; freelance missions (ZenQuality) in parallel.
- Geography: zone **Loire-Atlantique · Vendée · Morbihan**. Never mention
  Yerres or the Essonne. Presence, in order of preference: full remote →
  hybrid in the zone → on-site in the zone → Paris only as a fallback, and
  only hybrid at 1–2 days per month maximum.

---

## Exceptions to global rules

None — global rules apply.

---

## Workflow expectations

- Edits to `index.html` or `CV_Bastien_Chanot.html` must preserve the
  palette + typography + structure unless explicitly asked to change them.
- After editing `CV_Bastien_Chanot.html`, regenerate the PDF.
- After editing index.html's inline `<script>`, recompute the CSP hash and
  update `nginx-security-headers.conf` (script-src is hash-pinned — a stale
  hash silently disables the JS in prod):
  ```bash
  python3 -c "import hashlib,base64,re;h=base64.b64encode(hashlib.sha256(re.search(r'<script>(.*?)</script>',open('index.html',encoding='utf-8').read(),re.S).group(1).encode()).digest()).decode();print('sha256-'+h)"
  ```
- Never add external dependencies beyond Google Fonts.
- Never add tracking, analytics, cookie banners or third-party scripts.
- Always test in mobile width (375px) and desktop (1440px) before claiming done.
- The HTTP server bound to `192.168.1.101:8000` is for local LAN testing only.
