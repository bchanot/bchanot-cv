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

## Tour 2026-07-05 — AUTO — branch chore/tour-2026-07-05 — 2 iterations — CONVERGED

Fix pass over the 2026-07-05 report-only findings (user GO + 3 scope answers:
fix Docker path / strict palette conformity / prod vhost provided).

| ID | Axis | File | Sev | Finding | Status |
|----|------|------|-----|---------|--------|
| SEC-1 | security | Dockerfile | high | root master in container | fixed ba13d69 — `nginxinc/nginx-unprivileged:1.28-alpine` digest-pinned, uid 101 (verified `id` in container), `USER root` scoped to the one `rm`, cap_add dropped — **BREAKING**: container port 80 → 8080 (compose mapping/healthcheck updated same commit; VPS `.env PORT=2937` unaffected: mapping is `127.0.0.1:${PORT}:8080`) |
| SEC-2 | security | nginx.conf | med | add_header inheritance dropped all security headers | fixed ba13d69 — shared `nginx-security-headers.conf` snippet re-included in every location; live-style oracle in hardened container: 5/5 headers on `/`, `.html`, `.pdf`, favicon |
| SEC-3 | security | VPS vhost | med | HSTS missing end-to-end | fixed IN PROD by owner (front vhost patch) — live-verified `strict-transport-security: max-age=31536000` on bchanot.fr + www |
| SEC-4 | security | Dockerfile | med | EOL base image, tag-only pin | fixed ba13d69 (1.28-alpine stable + digest) |
| SEC-5 | security | nginx.conf | low | trust-all set_real_ip_from | fixed ba13d69 (→ 127.0.0.1, matches compose bind) |
| SEC-6 | security | nginx.conf + VPS vhost | low | server version leak | fixed ba13d69 (`server_tokens off` in-repo) + IN PROD by owner (front) — live-verified `server: nginx` |
| SEC-7 | security | snippet:12 | low/info | CSP `unsafe-inline` | open/accepted — documented convention, static no-input site (it2 semgrep sole non-blocking note) |
| CLN-1 | clean | index.html + CV | - | 5× `background:#fff` | fixed 7e7bd66 → `var(--page)` (user chose strict conformity; visual change: cards blend with parchment, borders kept) |
| CLN-2 | clean | CV html | - | dead `.screen-label` | fixed 7e7bd66 |
| CLN-5 | clean | index.html | - | transitions alive under reduced-motion | fixed 7e7bd66 (universal kill rule) |
| CLN-3 | clean | index.html | - | ~421-line card CSS duplication | open — refactor worth its own pass |
| CLN-4 | clean | index.html | - | 8 neutrals beyond strict palette | open — owner judgment call |
| REC-1 | reconcile | TODO/BDR-004 | - | prod topology CONFIRMED = BDR-004 as declared (native front proxy → container on 2937); earlier "native, no docker" premise was the misunderstanding — container IS the content server | consistent |
| DOC-1 | doc | README.md | - | .githooks row + hooksPath note; deploy section synced (unprivileged image, snippet, front/container split) | fixed 840632a |
| INV-1 | invariant | CV pdf | - | PDF regenerated with the HTML (weasyprint, same commit 7e7bd66) | held |

### Iterations
1. **It1** — fixes from the same-day report-only audit (tree unchanged since):
   security ba13d69 (docker build + in-container `nginx -t` + hardened run +
   4-location header oracle ALL PASS), clean 7e7bd66 (+PDF regen), doc
   840632a (via doc-commit.sh). Prod side: owner applied front vhost patch
   (HSTS + server_tokens), live-verified from here.
2. **It2 (convergence)** — fresh semgrep full scan: VERDICT PASS, 0 blocking
   (prior Dockerfile BLOCK resolved), 1 LOW reported (SEC-7 accepted); fresh
   clean re-audit: CONVERGED-CLEAN yes, prior findings resolved, zero new
   (CSS braces balanced, README↔infra aligned). Zero fixes → CONVERGED.

### Residuals (open)
SEC-7 (accepted CSP convention), CLN-3 (dedup refactor), CLN-4 (palette
judgment). Prod content headers (CSP/XCTO/XFO…) appear once the fixed
container is redeployed: merge → VPS `git pull && docker compose up -d
--build` → verify `curl -sI https://bchanot.fr/ | grep -i x-content`.

Commits: 4 (fix/clean/docs + this report). BREAKING: 1 (SEC-1, container
port — compose covered). Branch left UNMERGED — `gitflow finish` on GO.

## Follow-up 2026-07-05 — residuals closed (chore/tour-residuals, user GO)

| ID | Resolution |
|----|-----------|
| CLN-3 | Card CSS deduplicated via grouped selectors (shared chrome/hover/head/title/tag blocks + per-class specifics), zero HTML change, cascade-order verified (no interfering same-specificity rules between shared and specific blocks), braces 195/195. Honest correction: the audited "~421 redundant lines" was overstated — real net dedup ≈ 60 lines. |
| CLN-4 | Norm aligned with reality: the 8 functional neutrals (inks, rule/tag, 2 green intermediates) are now DOCUMENTED as allowed in CLAUDE.md (+ README pointer). "Any color outside the two lists is a violation" keeps the norm enforceable. |
| SEC-7 | script-src hardened: `unsafe-inline` replaced by the sha256 hash of the single inline script (index has zero style/script attributes). style-src keeps `unsafe-inline` (CV carries 2 style attributes + single-file convention) — documented. NEW INVARIANT in CLAUDE.md: recompute the hash after any inline-JS edit (stale hash = JS silently blocked in prod). |
| INF-2 | CORRECTION: false positive in the 2026-07-05 report-only run — `.gitignore` exists (549B) and covers the expected classes. No action was ever needed. |

## Tour 2026-07-05-2 — AUTO — branch chore/tour-2026-07-05-2 — 2 iterations — CONVERGED

Re-run of /tour on develop (d7256ff) after the day's earlier tours merged. Goal:
verify no regression + catch anything new. Branch suffixed `-2` to keep this
header distinct from the earlier converged run. gstack OFF → optional It1 cso
posture add-on not run; the security floor (security-auditor + pinned semgrep)
ran BOTH iterations, not degraded. No package.json/Makefile → no automated
tests/lint/build; project checks = domain invariants (CSP-hash, PDF↔HTML).

| ID | Axis | File | Sev | Finding | Status |
|----|------|------|-----|---------|--------|
| SEC-1 | security | (full tree) | - | Fresh semgrep both iterations → VERDICT PASS, 0 blocking. Sole note: `style-src 'unsafe-inline'` (accepted single-file convention, It1==It2). No regression from the prior SEC fixes; script-src hash still matches inline script | pass |
| CLN-1 | clean | index.html:347 | - | dead `.reveal.d6` rule (markup uses reveal d1–d5 only) | fixed 30b0e44 |
| CLN-2 | clean | CV:408 | - | dead `position: running(siteFooter)` — no `element(siteFooter)` consumer; `.footer-bar` is `display:none` in @media print (@page auto-numbered footer replaces it); on screen running() is an invalid position value, ignored | fixed 30b0e44 |
| CLN-3 | clean | CV:438 | - | no-op `box-shadow: none` on `.page` (`.page` sets a shadow nowhere; weasyprint ignores box-shadow entirely — confirmed by its own warning) | fixed 30b0e44 |
| CLN-4 | clean | CV:315 | - | dead `.skills-grid { font-size: 8.4pt }` — every direct child is a `.skill-label`(9.5pt)/`.skill-values`(10pt) div; no bare text node, no em-dependency → never renders | fixed 30b0e44 |
| CLN-5 | clean | CV:46-48,54,316 | - | stray blank lines (triple blank before `.page`, blanks inside `.page`/`.skills-grid`) | fixed 30b0e44 |
| CLN-6 | a11y | index.html:1003,1007 | - | 2 decorative `.arrow` SVGs miss the `aria-hidden="true"` the sibling download arrow (1011) has. NOT auto-fixed: adding it changes the a11y tree → outside the clean phase's behavior-preserving scope (belongs to an a11y pass; cf. TODO "WCAG AA contrast") | open (suggested) |
| CLN-7 | norm | index.html:931 | - | `.footer` bg `#061008` is off-palette (darker than `--dark #0d1b12`, `--g900 #0e3320`). Design system documents footer = `#0d1b12`. Fix changes rendering (slightly lighter footer) → owner decision, not auto-fixed | open (suggested) |
| CLN-8 | norm | CV:252,135-136,434-435 | - | off-palette colors: `#a8d4bc` tag border (252), gradient stops `#edeadf`/`#f2efe6` (136/435), texture fill `rgba(26,71,48,0.05)` (135/434). All rendering-changing → owner decision, not auto-fixed | open (suggested) |
| CLN-9 | content | index.html vs CV:507-508 | - | profile-state wording drift: landing "Pays de la Loire / remote or 1–2j Paris" vs CV "région nantaise / hybride Nantes / 1–2j Paris" (not contradictory — Nantes ∈ PdL — but CV adds "hybride Nantes"). CLAUDE.md requires cross-file consistency → owner picks canonical wording, not auto-fixed | open (suggested) |
| REC-1 | reconcile | .claude/memory/decisions.md | - | **BDR-004 stale**: text says `nginx:1.27-alpine` / container port 80 / "HSTS omitted at container", but the real Dockerfile+compose (post 2026-07-05 SEC-1 fix) = `nginxinc/nginx-unprivileged:1.28-alpine` / port 8080 / uid 101. That tour never added a superseding decision (index stops at BDR-005). Append-only registry + tour-read-only → SUGGEST a superseding **BDR-006**. README deploy section is already correct | suggested |
| REC-2 | reconcile | .claude/memory/decisions.md | - | BDR-002 "Warnings connus: `box-shadow:none` ignoré par weasyprint" — that declaration was removed this tour (CLN-3), so the documented warning no longer fires. Minor note to add when BDR-002 is next touched | suggested |
| REC-3 | reconcile | TODO.md + registries | - | ZERO false-done. Oracles: 1369d27 exists ✓; `og:image` absent = TODO item genuinely open ✓; CV favicon-block not mirrored = open, matches BDR-005 note ✓; WCAG-contrast + real-mobile-QA open ✓; develop==origin/develop (d7256ff), branch +1 unmerged ✓; BLK-001 resolved, favicon assets present ✓ | consistent |
| DOC-1 | doc | README.md | - | doc-syncer automatic mode → `PATCHED_FILES: (none)`. Deploy section already reflects unprivileged image/port 8080 (prior tour sync); file table matches root inventory; cleanup touched nothing user-facing | no-op |
| INV-1 | invariant | index.html / CV pdf | - | CSP hash `sha256-Al1M34KxI6Ye5Viu6aO//7CYyaLzqtpG9GX95FFlSOY=` recomputed == pinned (inline `<script>` untouched) ✓; PDF regenerated byte-identical to the pre-edit baseline (text sha256 083055…96a8 + per-page PNG @150dpi render hash all match) → PDF=HTML invariant holds, PDF file unchanged | held |

### Iterations
1. **It1** — security-auditor fresh semgrep (94 rules / 25 files → VERDICT PASS,
   1 accepted LOW) + read-only clean audit (13 findings: C1–C8, N1–N5). Applied
   behavior-preserving fixes CLN-1..5 (commit 30b0e44); proven behavior-preserving
   (PDF renders pixel-identical, CSP hash unchanged). Fresh `analyzer` re-verify:
   RE-VERIFY PASS, braces balanced, zero new. Reconcile (report-only): BDR-004
   drift + BDR-002 note + zero false-done. Doc: no drift.
2. **It2 (convergence)** — fresh full-tree semgrep: VERDICT PASS, identical to It1,
   0 new blocking. Clean stability: 4 removed selectors GONE, braces balanced
   (index 204/204, CV 68/68), known-open findings (CLN-6..9) persist = NOT new,
   zero new introduced. Zero fixes → CONVERGED.

### Residuals (open — all require owner judgment, none auto-fixable behavior-preservingly)
CLN-6 (arrows aria-hidden — a11y pass), CLN-7/8 (off-palette colors — design
decision), CLN-9 (profile-state wording — copy canonicalization), REC-1
(superseding BDR-006 for the hardened container), REC-2 (BDR-002 warning note).
SEC accepted-LOW (`style-src 'unsafe-inline'`) unchanged from prior runs.

Checks: semgrep PASS (both it.), CSP-hash MATCH, PDF↔HTML byte-identical render,
CSS braces balanced. No automated tests/lint/build (static site).
Commits: 2 (clean 30b0e44 + this report). BREAKING: 0. Branch left UNMERGED.
Scratch reports (.tour-semgrep, .tour-clean, .tour-semgrep-it2) folded here then
deleted (STEP 3.2).

## Follow-up 2026-07-05-2 — all 5 residuals closed (chore/tour-2026-07-05-2, owner GO)

| ID | Resolution |
|----|-----------|
| CLN-6 | `aria-hidden="true"` added to the 2 decorative CTA arrows (match sibling download arrow). Visual identical, a11y-tree only. Commit `607124a`. |
| CLN-7 | `.footer` bg `#061008` → `var(--dark)` #0d1b12 (the design-system footer color). Commit `ede7576`. |
| CLN-8 | CV off-palette → tokens: `.tag` border `#a8d4bc` → `var(--g300)` (nearest visible green); body+print texture `rgba(26,71,48,.05)` → `rgba(27,94,59,.05)` (--g700); gradient stops `#edeadf`/`#f2efe6` → `var(--tag)`/`var(--page)`. PDF regenerated, render verified (2 pages, layout intact, page-1 eyeballed). Commit `ede7576`. |
| CLN-9 | Owner chose the CV wording as canonical (Option B): landing about-para + callout aligned to "installation région nantaise prévue" + "hybride Nantes"; `CLAUDE.md` geography note updated to match. CV unchanged. Commit `f515875` → BDR-007. |
| REC-1 | BDR-004 drift resolved by superseding entry **BDR-006** (nginx-unprivileged:1.28 / port 8080 / uid 101). |
| REC-2 | BDR-002 "box-shadow warning" note now historical (declaration removed in `30b0e44`) — left as-is (append-only registry), noted here. |

Checks: CSP-hash MATCH, braces balanced (index 204/204, CV 68/68), PDF 2 pages.
Commits: 3 fixes (`607124a`/`ede7576`/`f515875`) + capitalize (BDR-006/007, LRN-003,
journal) + this follow-up. Branch finished → develop + pushed on owner GO.

## Tour 2026-07-05-3 — AUTO — branch chore/tour-2026-07-05-3 — 3 iterations — CONVERGED

Third run of the day, on develop 7967aff (all prior tour residuals merged).
gstack ON → cso posture add-on ran it1 (it was OFF for run -2) — and caught the
run's only HIGH. Session-limit pause mid-it3 (2026-07-05→06); both it3 agents
resumed from transcript, tree unchanged, no audit gap.

| ID | Axis | File | Sev | Finding | Status |
|----|------|------|-----|---------|--------|
| SEC-1 | security | Dockerfile:5 | high | base `nginx-unprivileged:1.28-alpine` (correct this morning) now on a RETIRED stable branch — 2026-05-13 nginx batch (CVE-2026-42945, rewrite-module buffer overflow, RCE/DoS-class) fixed only in 1.30.1+/1.31.1+, never backported to 1.28.x; digest pin froze the vulnerable build | fixed 1aa97f0 — `1.30-alpine@fd3314e3…` (nginx/1.30.3). Verified: build, `nginx -t`, uid 101, hardened run 5/5 headers + HTTP 200 on /, .html, .pdf, favicon. Not BREAKING (same port/contract); prod needs rebuild+redeploy after merge |
| SEC-2 | security | (full tree) | - | semgrep floor: fresh scan ALL 3 iterations → VERDICT PASS, 0 findings (94 rules; 23→28 files as scratch reports accrued). cso it1: all same-day fixes hold; secrets sweep tree + 36-commit history clean | pass |
| CLN-1 | clean | CV:490 | - | leftover double blank after `<body>` (run -2's CLN-5 went triple→double) | fixed 613bfc0 |
| CLN-2 | clean | nginx.conf:67 | - | dead `deny all;` — `return 404` fires at rewrite phase, access phase never reached | fixed 613bfc0 — dotfile-404 oracle PASS |
| CLN-3 | clean | .dockerignore:14 | - | phantom `nginx.conf.bak` (never existed in tree or history) | fixed 613bfc0 |
| CLN-4 | clean | CV | - | duplicated rules: `.xp/.project/.edu-header`, 3 date chips (5/7 shared), `.xp-role`≡`.edu-degree`, `.lang-item`≡`.interest-tag` → shared block + per-class overrides | fixed 613bfc0 — PDF text-hash + per-page render-hash + full byte-identity vs committed PDF (LRN-003) |
| CLN-5 | clean | CV:528,585 | - | 2 byte-identical inline `style=` attrs → `.inline-link` class; snippet comment ("style attributes in the CV") synced | fixed 613bfc0 — CV now zero style attrs |
| CLN-6 | clean | index:505/761 | - | `.stack-note code`≡`.theme-list code` minus padding → grouped | fixed 613bfc0 |
| CLN-7 | clean | CV:43-44,430 | - | no-op body `margin/padding` (universal reset covers) | fixed 613bfc0 |
| CLN-8 | clean | index:700-701 | - | 2 no-op `.formation .timeline*` overrides restating base values (also removed a latent same-specificity override of the `.current` ring) | fixed 613bfc0 |
| J1 | norm | index+CV (12 sites) | - | `#fff`/rgba-white family (text-on-dark + 4% overlay) outside BOTH documented palette lists — de-facto accepted, undocumented | open — document as 3rd allowed family in CLAUDE.md, or map to tokens (visible change) |
| J2 | norm | CV headings | - | CV section titles/roles mono/sans vs CLAUDE.md "Fraunces = section titles, role headings" — deliberate compact-CV style, unflagged by all prior passes | open — document CV exception (recommended) or restyle |
| J3 | norm | CV:204 | - | `border-radius: 10px` on lang/interest tags — >6px unless counted as pills | open — owner call |
| J4 | config | nginx.conf | - | regex-location order lets hypothetical `/.foo.html` hit the caching block before the dotfile block (both still 404 — file absent; defense-in-depth only) | open — optional reorder |
| J5 | config | Dockerfile+compose | - | healthcheck duplicated (compose fully overrides image HEALTHCHECK, identical params — one always inert) | open — owner call (image stays self-checking without compose) |
| N1 | clean | both font URLs | info | unused Google Fonts faces (index: Fraunces 0,300/0,500/0,700 + DM Sans 300; CV: Fraunces 0,300/0,600 + DM Sans 300) | open — CV half provable via render-hash; index half needs a visual oracle (browser) → owner GO |
| N2 | content | CV:485/498/517 | - | date chips in English (`Apr 2026 - present`…) vs French-copy rule + hyphen/en-dash inconsistency | open — content change, owner call |
| N3 | clean | index:863-869 | info | `.contact-grid` grid declarations no-op around single child — removing `display:grid` can alter margin-collapsing, no render oracle | open |
| N4 | config | nginx.conf:39 | info | `application/pdf` in gzip_types — compressing already-flate-compressed format; removal changes observable response header | open — owner call |
| REC-1 | reconcile | TODO + registries | - | ZERO pre-existing drift. Oracles: CSP hash pinned==computed ✓, PDF↔HTML same commit ede7576 + byte-identical render ✓, BDR-006 (unprivileged/8080) + BDR-007 (Nantes wording ×2 index, ×1 CV) match tree ✓, BLK-001 COPY line holds ✓, og:image + CV-favicon TODO items genuinely open ✓, develop==origin ✓ | consistent |
| REC-2 | reconcile | decisions.md BDR-006 | - | SEC-1 bump makes BDR-006's "1.28-alpine" version detail stale (decision itself — unprivileged base + 8080 — unchanged). Registry read-only for tour | suggested — annotate via /reconcile or /capitalize |
| DOC-1 | doc | README.md:91 | - | stale `1.28-alpine` ref after SEC-1 | fixed 2f5e51a (doc-syncer automatic, single-line) |
| INV-1 | invariant | CSP + PDF | - | CSP hash MATCH all iterations (script byte-untouched); post-clean PDF byte-identical to committed (text sha256 083055…96a8 + both page render-hashes) → PDF file unchanged, nothing to regen | held |

### Iterations
1. **It1** — parallel: security-auditor (semgrep PASS 0 findings) + cso posture
   (gstack ON, it1-only: 0c/1h/0m/0l/6i — the HIGH = SEC-1, sourced
   endoflife.date + nginx advisories) + clean audit (8 fixable / 5 judgment).
   Fixes: 1aa97f0 (security, oracle-verified) + 613bfc0 (clean F1–F8, 5 files,
   net −54 lines, render-hash proof). Re-verify (fresh analyzer): PASS — cascade
   safety, zero dead selectors, commits scoped. Reconcile: zero drift + REC-2.
   Doc-syncer automatic: README 1.28→1.30 (2f5e51a via scoped fallback commit).
2. **It2** — fresh semgrep PASS; clean stability: it1 fixes hold (braces
   203/203, 67/67), but 4 NEW info/judgment findings (N1–N4). Fix policy: none
   provably behavior-preserving with available oracles (N1-index/N3 need a
   browser render; N2/N4 owner calls) → 0 applied, all catalogued open. New
   findings appeared → iteration 3 required.
3. **It3 (convergence, at bound)** — fresh semgrep PASS (0 findings); fresh
   clean sweep against the full catalogue: stability PASS, borderline items
   considered and rejected below threshold, ZERO new. Zero fixes + zero new →
   CONVERGED.

### Residuals (open — all owner-judgment, none auto-fixable with available oracles)
J1 (document white family — recommended), J2 (document CV typography
exception — recommended), J3 (10px radius), J4 (dotfile regex order), J5
(healthcheck dup), N1 (font trim — CV provable, index needs eyeball), N2
(English date chips), N3 (.contact-grid), N4 (gzip pdf), REC-2 (BDR-006
version note). Standing accepted/TODO: SEC-7 CSP style-src, og:image, CV
favicon block, WCAG contrast, real-mobile QA.

### Prod follow-up
SEC-1 lands in prod only after merge: VPS `git pull && docker compose up -d
--build` → verify `curl -sI https://bchanot.fr/ | grep -i server` + container
`nginx -v` = 1.30.3.

Checks: semgrep PASS ×3, docker build + nginx -t + hardened-run 4-location
header oracle PASS, CSP-hash MATCH, PDF byte-identical, braces 203/203 + 67/67.
No automated tests/lint/build (static site). Commits: 4 (fix/clean/docs + this
report). BREAKING: 0. Branch left UNMERGED — `gitflow finish` on owner GO.
Scratch reports (.tour-semgrep ×3, .tour-cso, .tour-clean ×3) folded here then
deleted (STEP 3.2).
