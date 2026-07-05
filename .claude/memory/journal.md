---
type: journal
schema:
  entry: one date heading per working session
  body: 3-5 lines max - what was done, decided, blocked
rules:
  - One heading per date (YYYY-MM-DD), not per session.
  - Append at the end. Never edit past entries.
  - Keep it terse. Details belong in decisions/learnings/blockers - this is a timeline only.
---

# Journal

## 2026-05-15

- Bootstrap `index.html`: hero stagger, sticky nav, stack cards 6 cat, timeline parcours, contact dark, footer.
- Palette + 3 polices câblées via `:root`. CSS inline + JS vanilla. Aucune dep sauf Google Fonts.
- CV HTML mis à jour: header suffix "· mobilité Pays de la Loire" à côté Yerres.
- PDF CV regen via `weasyprint`. Warning `box-shadow: none` ignoré.
- Serveur dev: `python3 -m http.server 8000 --bind 0.0.0.0` → LAN sur `192.168.1.101:8000`.
- Position pro précisée: CDI embarqué/logiciel prioritaire, freelance ZenQuality parallèle, remote ou Paris 1-2 j/mois, mobilité Pays de la Loire.
- Squelette `.claude/` + `CLAUDE.md` + `README.md` créés a posteriori (init-project skippé init pour single-file livrable).
- Docker setup: `Dockerfile` (nginx:1.27-alpine), `nginx.conf` (gzip+cache+CSP), `docker-compose.yml` (`PORT` env, 127.0.0.1 bind, hardened). Decision logged BDR-004.
- Git init + remote `https://git.bchanot.fr/bchanot/bchanot-cv.git`. 2 commits baseline + docker, branch renamed `main`→`master` to match remote default. Pushed `7957b04..54e8300`.
- Certbot install failed for `bchanot.fr`: diagnosed mismatch — `sites-available/bchanot.fr` contained `server_name autreprojet.fr;` (copy-paste leftover). Fix: sed rewrite. Learning logged LRN-001.
- Commits: `54e8300..7957b04` + user's `414bce1` (CV final).
- Dedicated `#formation` section added between Parcours + Contact: timeline reused, 3 theme-cards inside École 42 entry (Systèmes/Kernel · Bas niveau · Sécurité/Algo), TSRIT block with `Félicitations du jury` honors pill. Removed `.contact-side` aside + dead CSS, `.contact-list` 2-col on >=768px to fill freed space. Nav link inserted. Commit `1d5fbfa`.
- Formation copy fix: title now "Deux écoles, un fil rouge : le bas niveau."; strip `<em>` from section-intro for consistency; rewrite École 42 role+desc (kernel/memory/shell/security); drop false TSRIT li claiming CareGame CDI (CareGame stage was 2018-2019 during 42, not 2015 TSRIT). 1 file, +4/-5.

## 2026-05-17

- Landing extended-vitrine refactor shipped (commit `1369d27`): meta/title sync CV, hero subtitle "Systèmes · Embarqué · Backend", stack 6→8 cards (drop VMware/Gitflow/Agile, add cgroups/namespaces/SELinux/GitHub Actions + Cloud-Infra + IA-Outils, Familier avec C++), Parcours 3 entries rewritten bullets+stack pills (lone-wolf wording purged, Deewee dates corrected fév→nov 2017), new Projets section (Git auto-hébergé + Homelab), new Méthode section (5 points), contact email → bastien@bchanot.fr.
- Favicon set added (commit `ef31fb3`): SVG primary + PIL-generated PNG/ICO/apple-touch. Brand pulse-dot translated to icon. BDR-005 + LRN-002 logged.
- CV files (`CV_Bastien_Chanot.html`, `.pdf`) untouched — user's WIP M state, off-scope per brief.
- User pushed + reported favicon 404 in prod. Root cause: Dockerfile selective `COPY` whitelist never included favicon files. Fix shipped (commit `f1e4392`): COPY line appended + nginx long-cache rule for image assets. BLK-001 logged. VPS rebuild required.

## 2026-07-05

- Grouped tours (security+clean+reconcile+doc): container hardened (SEC-1..7 → nginx-unprivileged:1.28 / port 8080 / uid 101, per-location security headers, `server_tokens off`, CSP script-src hash-pinned), palette + dead-code clean, README synced. Merged via chore/tour + chore/tour-residuals. Detail in `.claude/audits/TOUR.md`.
- Re-run tour (chore/tour-2026-07-05-2) CONVERGED 2 it: fresh semgrep PASS, dead CSS removed (`30b0e44`, render-hash proven behavior-preserving → LRN-003), reconcile caught BDR-004 drift, doc no-drift.
- Closed all 5 residuals on owner GO: CLN-6 aria-hidden CTA arrows (`607124a`), CLN-7/8 palette conformance (5 off-palette colors → tokens, PDF regen render-verified, `ede7576`), CLN-9 geo aligned landing→CV = Nantes relocation (`f515875`).
- Decided: BDR-006 (hardened container, supersedes BDR-004 infra), BDR-007 (geo canonical = Nantes, supersedes BDR-003 geo).
- Branch chore/tour-2026-07-05-2 finished → develop + pushed.

## 2026-07-06

- Tour 2026-07-05-3 finished (session-limit pause mid-it3, agents transcript-resumed): CONVERGED 3 it. SEC-1 HIGH fixed — base 1.28→1.30-alpine, CVE-2026-42945 (`1aa97f0`); clean F1-F8 (`613bfc0`, −54 lines, render-hash proven); README synced (`2f5e51a`).
- All 10 residuals closed on owner GO: Google Fonts trimmed both files (CV render-hash identical, index browser-verified 375+1440), CV date chips French + en-dash, CV tags → 999px pills, contact-grid no-ops dropped, nginx dotfile block reordered first, PDF gzip dropped, compose healthcheck deduped (image healthcheck verified healthy), CLAUDE.md white-family + CV-typography exception documented, BDR-006 annotated (1.30 bump).
- LRN-004 (pinned base = frozen CVE exposure) + EVAL-001 (tour verdict) logged. Branch chore/tour-2026-07-05-3 → develop on owner GO (this session).
