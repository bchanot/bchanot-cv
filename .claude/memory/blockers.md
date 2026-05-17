---
type: blockers_registry
entry_prefix: BLK
schema:
  id: BLK-XXX
  date: YYYY-MM-DD
  friction: string (what was blocked)
  real_cause: string (root cause, not symptom)
  solution: string (workaround or fix)
  status: [open | resolved | upstream]
rules:
  - Open a blocker as soon as friction > 15 min wasted. Close it with a real cause, not "moved on".
  - Link to upstream issue / PR / commit when applicable.
  - If cause is a bug in a dependency, set status upstream with a pointer to the tracker.
---

# Blockers registry (BLK)

## Index

| ID | Date | Friction | Status |
|----|------|---------|--------|
| BLK-001 | 2026-05-17 | Favicon 404 in prod after rebuild — Dockerfile selective COPY hid new repo files | resolved |

---

## BLK-001 — Favicon 404 in prod after Docker rebuild

- **Date**: 2026-05-17
- **Friction**: User reported favicon missing on `bchanot.fr` prod despite new landing page being live. `docker compose up -d --build` did not fix it.
- **Real cause**: `Dockerfile` uses selective `COPY index.html ./`, `COPY CV_*` (whitelist), not `COPY . ./`. Favicon assets added in commit `ef31fb3` (`favicon.svg`, `favicon-32.png`, `favicon.ico`, `apple-touch-icon.png`) were never wired into Dockerfile → never entered image layers → 404 from container even after full rebuild. New `index.html` worked because it was already on the COPY whitelist.
- **Solution**: Append `COPY favicon.svg favicon-32.png favicon.ico apple-touch-icon.png ./` to Dockerfile (commit `f1e4392`). Matching nginx cache rule for `*.{ico,svg,png,jpg,jpeg,gif,webp}` added (30d immutable). VPS rebuild required after pull.
- **Status**: resolved
- **Future application**: Whenever the repo grows a new top-level asset that must ship in the image, audit Dockerfile COPY whitelist immediately. Consider replacing the whitelist with `COPY index.html CV_*.html CV_*.pdf favicon.* apple-touch-icon.png ./` or a glob-friendly pattern if asset count grows further.

## BLK-XXX - <friction>

- **Date** : YYYY-MM-DD
- **Friction** : <ce qui était bloqué>
- **Cause réelle** : <cause racine>
- **Solution** : <workaround ou fix>
- **Statut** : open | resolved | upstream

-->
