# TODO — bchanot.fr

State of the landing page + CV project. Append-only: keep history readable.

---

## Current

- Landing page `index.html` shipped (single file, inline CSS + JS).
- CV `CV_Bastien_Chanot.html` + matching PDF regenerated via weasyprint.
- Local serve verified at `http://192.168.1.101:8000/`.

## 2026-05-17 — Extended-vitrine refactor (shipped — commit 1369d27)

Align landing with CV + add depth (Projets, Méthode, bullet-format Parcours).

- [x] Meta description sync (kernel, AOSP, cloud gaming, GPU)
- [x] Nav links: add #projets + #methode
- [x] Hero: titre "Systèmes · Embarqué · Backend", banner "Backend · Cloud"
- [x] About: expand paragraphs (pourquoi bas niveau / cherche / pas envie)
- [x] Stack: Langages (Java AOSP, drop Python order, + Familier avec C++) · Conteneurs (- VMware + cgroups/namespaces) · Systèmes (+ SELinux) · DevOps (- Gitflow/Agile, + GitHub Actions) · NEW Cloud/Infra · NEW IA/Outils
- [x] Parcours: kill "seul"/"responsable unique" — reformuler autonomie+collab
- [x] CareGame: intro contexte + 9 bullets + stack pills
- [x] ZenQuality: intro CDI + 3 bullets + stack pills
- [x] Deewee: dates Fév-Nov 2017 + contract line + 2 bullets + stack pills
- [x] NEW Projets section (entre Parcours et Formation): Git source + Homelab
- [x] NEW Méthode section (entre Formation et Contact): 5 points bundle A
- [x] Contact email → bastien@bchanot.fr
- [x] CSS extensions: timeline-bullets, timeline-stack, timeline-contract, projects-grid, methode-list

## Known follow-ups

- Visual QA on real mobile device (375 px) — not just emulator.
- Verify WCAG AA contrast on all green-on-parchment text.
- Hosting: nginx VPS + Docker container behind reverse proxy (BDR-004) — decided & live.
- DNS / domain for `bchanot.fr` — configured (site live in prod).
- Consider OG image — not yet present.
- Mirror favicon link block into `CV_Bastien_Chanot.html` when user finalizes CV edits (currently /favicon.ico auto-served as legacy fallback).

## Open ideas (not committed)

- Light "what I'm working on right now" section (single line under hero).
- Add a Gogs / GitHub link if a clean public repo is curated first.
- Print-stylesheet polish for `CV_Bastien_Chanot.html` if weasyprint output drifts.

---

> Mark items done by moving them to `.claude/memory/journal.md` with a date heading.
