# TOUR — audit & fix log (append-only)

## Tour 2026-07-05 — REPORT-ONLY — 1 iteration — no branch, zero fixes

Mode: `--report-only` (first real run of /tour). All findings `open`/`suggested`
— nothing was modified. Checks detected: NONE (no tests/lint/build — static
site, no package manager; report line INF-1).

| ID | Axis | File | Sev | Finding | Status |
|----|------|------|-----|---------|--------|
| SEC-1 | security | Dockerfile:27 | high | no `USER` directive — nginx master runs as root in container (semgrep `missing-user`, BLOCK-class). Compose hardening (read_only, cap_drop ALL, no-new-privileges, 127.0.0.1 bind) shrinks blast radius but root master remains. Fix: `FROM nginxinc/nginx-unprivileged:1.29-alpine` (uid 101, port 8080) + adjust EXPOSE/ports/healthcheck | open |
| SEC-2 | security | nginx.conf:46-62 | med | **add_header inheritance trap**: location blocks (.html/.pdf/images) set their own `Cache-Control` → ALL 5 server-level security headers (CSP, X-Content-Type-Options, X-Frame-Options, Referrer-Policy, Permissions-Policy) dropped on real responses. Confirmed live: pages send zero security headers, only 404 path carries them. Fix: repeat the 5 add_header in each location block (or `include headers.conf`) | open |
| SEC-3 | security | nginx.conf | med | HSTS missing end-to-end — delegated to outer TLS proxy but live site doesn't send it. Fix at the front proxy (VPS) or add here behind X-Forwarded-Proto check | open |
| SEC-4 | security | Dockerfile:4 | med | base `nginx:1.27-alpine` = retired mainline (no security fixes since 2025-04), tag-pinned without digest. Fix: bump to current stable + digest pin | open |
| SEC-5 | security | nginx.conf:26 | low | `set_real_ip_from 0.0.0.0/0` trusts X-Forwarded-For from anywhere — safe only while the 127.0.0.1 bind holds. Fix: restrict to the front proxy IP | open |
| SEC-6 | security | nginx.conf | low | no `server_tokens off` in this config; live front proxy also leaks `nginx/1.24.0 (Ubuntu)` (host-level, outside repo — VPS action) | open |
| SEC-7 | security | nginx.conf:22 | info | CSP `unsafe-inline` script/style — inherent to the documented single-file convention; script hash possible if wanted. Google Fonts = only external dep (conforms; GDPR self-host note). mailto/tel in clear = deliberate for a CV | open/accepted |
| CLN-1 | clean | index.html + CV html | - | 5 × pure-white bg (`#fff`) in `.stack-card`, `.project-card`, `.theme-card`, `.methode-item`, CV `body` — forbidden by project CLAUDE.md → `var(--page)` `#f5f3ec` | suggested |
| CLN-2 | clean | CV_Bastien_Chanot.html | - | dead CSS rule `.screen-label` (no matching element) | suggested |
| CLN-3 | clean | index.html | - | 4 card components duplicate ~80% of base+hover styles (~421 redundant lines) — collapsible into a shared `.card` base class | suggested |
| CLN-4 | clean | index.html | - | 8 colors beyond the strict 6-hex palette (`--dark-mid`, `--g900`, `--g050`, text neutrals…) — likely intentional neutrals; JUDGMENT CALL, not auto-fixable | suggested |
| CLN-5 | clean | index.html | - | CSS transitions stay active under `prefers-reduced-motion: reduce` (only animations disabled) — stricter conformity would zero transitions too | suggested |
| REC-1 | reconcile | .claude/* | - | ZERO drift. Oracles: 1369d27 exists ✓, PDF=HTML same commit 1ae73e0 (declared invariant holds) ✓, develop==origin ✓, BLK-001 resolved AND live-confirmed (favicon HTTP 200 in prod — VPS rebuild done) ✓. Open TODO items (OG image, favicon mirror into CV, mobile QA, WCAG contrast) verified genuinely open, not drift | consistent |
| DOC-1 | doc | README.md | - | Contents table omits `.githooks/` (active gitflow guard since 195188f, predates last README edit) + no clone note `git config core.hooksPath .githooks` | suggested |
| DOC-2 | doc | README.md | - | Contents table omits `.gitignore`/`.dockerignore` — conventionally skipped, low value | suggested |
| INF-1 | infra | - | - | no checks configured (tests/lint/build) — nothing to run in re-verify phase; acceptable for a zero-dependency static site | reported |

### Iterations
1. **It1 (report-only)** — 4 parallel read-only audits: security-auditor
   (semgrep 1.168.0, pinned rulesets, 91 rules / 18 files → VERDICT BLOCK(1)),
   cso posture (0 crit / 0 high / 3 med / 2 low / 5 info; secrets sweep of tree
   + full git history clean), clean audit (10 findings, config files clean),
   doc drift (2 drifts; README otherwise accurate; README-only judged right
   for this repo — DEPLOY.md split not warranted). Reconcile inline: zero
   drift. Report-only ⇒ zero fixes by design ⇒ single iteration = full
   picture; convergence loop N/A.

### Residuals (all — nothing fixed by design)
SEC-1 high (root in container), SEC-2/3/4 med (headers dropped / HSTS / EOL
base image), SEC-5/6 low, CLN-1..5, DOC-1/2. Highest-value single fix:
**SEC-2** (nginx add_header inheritance — live site currently serves zero
security headers).

### Suggested next step
`/tour ~/Documents/bchanot-cv` (auto mode) to fix on a `chore/tour-*` branch —
SEC-1/2/4 + CLN-1/2 are mechanical; SEC-3 needs the VPS side; CLN-3 is a
larger refactor worth its own pass; CLN-4 is the owner's judgment call.

Commits: 1 (this report — `.claude/**`, hook-exempt; no code touched).
Scratch reports (.tour-semgrep/.tour-cso/.tour-clean/.tour-doc) folded here
then deleted (STEP 3.2).
