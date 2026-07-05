# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] — 2026-07-06

First tagged release. Landing page + CV live at https://bchanot.fr, served by
a hardened nginx container behind the host reverse proxy.

### Security
- Container runs unprivileged: `nginxinc/nginx-unprivileged` digest-pinned,
  uid 101, internal port 8080; base at 1.30-alpine (nginx/1.30.3) covering
  CVE-2026-42945. Compose hardening: `read_only`, `cap_drop: ALL`,
  `no-new-privileges`, loopback-bound port.
- Security headers (CSP, X-Content-Type-Options, X-Frame-Options,
  Referrer-Policy, Permissions-Policy) re-included in every nginx location
  (add_header inheritance trap closed); `server_tokens off`; CSP `script-src`
  pinned to the inline script's sha256 hash; dotfile requests 404 ahead of
  the caching locations.

### Changed
- Palette strictly tokenized: 6 brand hexes + documented functional neutrals
  + white-on-dark family; off-palette colors mapped to tokens.
- CSS deduplicated via grouped selectors (landing cards, CV headers / date
  chips / roles / tags); dead rules and no-op declarations removed.
- Unused Google Fonts faces trimmed from both pages (CV proven
  render-identical; landing verified at 375 px and 1440 px).
- CV date chips in French with en-dashes; language/interest tags as true
  pills; profile geography aligned landing ↔ CV (Nantes relocation).
- `prefers-reduced-motion` disables transitions as well as animations;
  decorative CTA arrows removed from the accessibility tree.
- PDF served uncompressed (already flate-compressed); single container
  healthcheck (image `HEALTHCHECK`, inherited by compose).

### Added
- `version.txt` and this CHANGELOG — the release lineage starts here.
