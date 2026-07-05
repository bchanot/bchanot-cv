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
| LRN-003 | 2026-07-05 | Prove CSS cleanup behavior-preserving via before/after PDF render-hash | weasyprint / paged-media PDF projects |
| LRN-004 | 2026-07-06 | Digest-pinned base image = frozen CVE exposure; SAST can't see it | any Dockerfile with pinned FROM |

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

---

## LRN-003 — Prove CSS cleanup is behavior-preserving via before/after PDF render-hash

- **Date**: 2026-07-05
- **Pattern**: To confirm a CSS/HTML edit is truly behavior-preserving on a project whose deliverable is a weasyprint PDF: render a baseline PDF from the pre-edit HTML, apply the edit, regenerate, then compare (a) `pdftotext | sha256` and (b) per-page `pdftoppm -r 150 -png | sha256`. Text-hash alone misses `font-size`/color changes — the render-hash catches them. Identical render-hash = provably no visual change; and since weasyprint output is deterministic, an unchanged render yields a byte-identical PDF → nothing new to commit.
- **Context**: tour clean phase on `bchanot-cv` removed dead CSS (`.reveal.d6`, `position:running()`, no-op `box-shadow`, dead `.skills-grid font-size`). Render-hash matched on both pages → proven before commit `30b0e44`. The same tooling later confirmed the intentional palette edit DID change the render (expected), distinguishing dead-code removal from real visual change.
- **Future application**: Any weasyprint / paged-media project where you must tell "dead code removal" (must render identically) apart from "intended visual change". General trick: verify a refactor by hashing the rendered artifact, not the source.

---

## LRN-004 — Digest-pinned base image = frozen CVE exposure; SAST can't see it

- **Date**: 2026-07-06
- **Pattern**: Digest pin freezes image bytes → also freezes vulnerabilities. Pin correct at audit time can be HIGH same day: upstream retires stable branch, security batch lands only on newer branches, no backport. semgrep/SAST floor scans code, blind to base-image CVE freshness. Complementary posture pass required: base branch EOL status (endoflife.date) + vendor security advisories, every audit.
- **Context**: bchanot-cv tour 2026-07-05-3. `nginx-unprivileged:1.28-alpine` digest-pinned as SEC fix in morning run; same evening cso posture add-on flagged HIGH — 1.28 branch retired, CVE-2026-42945 (rewrite-module overflow) fixed 1.30.1+/1.31.1+ only. Two intervening semgrep-only tours saw nothing (gstack OFF → no cso). Bump commit `1aa97f0`.
- **Future application**: Any Dockerfile `FROM x@sha256:…` → security audit must include EOL + advisory check on the pinned branch, not just SAST. gstack ON → cso add-on covers it; OFF → manual endoflife.date + vendor advisory check.
