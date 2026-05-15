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
