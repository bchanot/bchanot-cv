---
type: learnings_registry
entry_prefix: LRN
schema:
  id: LRN-XXX
  date: YYYY-MM-DD
  pattern: string (what was observed, abstracted)
  context: string (where/when it happened - concrete)
  future_application: string (when to recall this)
rules:
  - Capture learnings that apply beyond the current task.
  - Abstract from the incident - the pattern is what is reusable, not the one-shot fact.
  - Link to source (commit, file, PR) when possible.
---

# Learnings registry (LRN)

## Index

| ID | Date | Pattern | Applies to |
|----|------|---------|------------|
| LRN-001 | 2026-05-15 | certbot --nginx matches `server_name`, not filename | nginx + certbot on multi-site VPS |
| LRN-002 | 2026-05-17 | PIL supersample ×8 + Lanczos = clean icon antialiasing | Python stdlib icon generation |

---

## LRN-001 — certbot --nginx matches `server_name`, not filename

- **Date**: 2026-05-15
- **Pattern**: `certbot install --cert-name X` (and `certbot --nginx -d X`) locates the target vhost by scanning every `server_name` directive in active nginx configs. The filename in `sites-available/` is irrelevant. A file named `X.conf` with `server_name Y;` inside will NOT be picked up for domain X.
- **Context**: `/etc/nginx/sites-available/bchanot.fr` existed and was symlinked into `sites-enabled/`, but its body still contained `server_name autreprojet.fr www.autreprojet.fr;` — a copy-paste leftover from a previous project. Certbot returned `Could not automatically find a matching server block for bchanot.fr`.
- **Future application**: Before running certbot on a multi-site VPS, `grep -n "server_name" /etc/nginx/sites-enabled/*` — confirm the target domain is actually declared inside, not just present in the filename. Same logic applies when troubleshooting "why is nginx serving the wrong site" — match by `server_name`, never by filename.

---

## LRN-002 — PIL supersample ×8 + Lanczos = clean small-format icon antialiasing

- **Date**: 2026-05-17
- **Pattern**: Render icon at 8× target size via `ImageDraw.rounded_rectangle` + `ellipse` on RGBA canvas, then `Image.resize((target, target), Image.LANCZOS)`. Output rivals `rsvg-convert` / `inkscape` for simple geometric shapes. Crisp at 16×16 favicon scale, no visible jaggies.
- **Context**: Generated `favicon-32.png`, `apple-touch-icon.png` (180×180), `favicon.ico` (multi-size 16/24/32/48) for `bchanot.fr` from scratch — no `rsvg-convert` / `inkscape` / `ImageMagick` on host. Single PIL script, ~20 lines.
- **Future application**: Any project needing a PNG/ICO icon set with a stdlib-only Python toolchain. Skip if shape is complex (text rendering, gradients, curves) — use `rsvg-convert` or commit a finalized PNG instead.
