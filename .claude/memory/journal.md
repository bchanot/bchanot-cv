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
