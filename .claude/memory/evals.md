---
type: evals_registry
entry_prefix: EVAL
schema:
  id: EVAL-XXX
  date: YYYY-MM-DD
  output: string (what was produced)
  method: string (how it was evaluated - manual read, test, benchmark, user feedback)
  anomalies: list of strings (what was wrong, missing, surprising)
  action: [keep | correct | deprecate]
rules:
  - Log an eval whenever you validate the quality of something Claude produced (report, audit, plan, generated code).
  - Action keep - the output is fit for purpose as-is.
  - Action correct - needs revision; capture what.
  - Action deprecate - the approach itself is flawed; link to the decision that replaces it.
---

# Evals registry (EVAL)

## Index

| ID | Date | Output | Action |
|----|------|--------|--------|
| EVAL-001 | 2026-07-06 | /tour run 2026-07-05-3 (3 it., converged) + residual closure | keep |

## EVAL-001 — /tour run 2026-07-05-3 + residual closure pass

- **Date**: 2026-07-06
- **Output**: 3-iteration tour (security/clean/reconcile/doc, converged at bound) + closure of all 10 residuals on owner GO. Commits `1aa97f0`/`613bfc0`/`2f5e51a` + follow-up.
- **Method**: oracle-based — semgrep ×3 (deterministic PASS), PDF render-hash (LRN-003) for behavior-preserving proofs, docker oracles (build, nginx -t, header/dotfile/gzip/healthcheck curls), headless-browser screenshots 375+1440 (index font trim), brace counts, CSP-hash pinned==computed.
- **Anomalies**: (1) cso add-on caught a HIGH (base-image CVE) two same-day semgrep-only tours missed — gstack was OFF then → LRN-004. (2) Fresh clean sweeps surfaced new info-tier nits each iteration (N1–N4 at it2) — convergence needed explicit reporting threshold in it3 prompt; bound of 3 did its job. (3) Session limit killed both it3 agents mid-flight — SendMessage transcript-resume recovered both, zero re-audit gap.
- **Action**: keep

<!-- Append entries below. Template:

## EVAL-XXX - <output>

- **Date** : YYYY-MM-DD
- **Output** : <ce qui a été produit>
- **Méthode** : <comment cela a été évalué>
- **Anomalies** : <ce qui est faux, manquant, surprenant>
- **Action** : keep | correct | deprecate

-->
