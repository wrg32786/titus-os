# Changelog

All notable changes to Titus OS are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

For changes to the kernel itself (the 15 numbered system documents and extended specs), see [`system/CHANGELOG.md`](system/CHANGELOG.md).

## [Unreleased]

(Pending changes for the next release land here.)

## [0.2.1] — 2026-04-26 — "Caddy elevation"

### Added
- **Doctrine plane (Caddy as canonical):**
  - `vault/concepts/Caddy.md` — promoted from local install. The full doctrine note for Caddy (the non-blocking skill router). Includes provenance: original Titus contribution, designed by Will Gwyn 2026-04-13. Not a port.
  - `vault/concepts/Suggestion Credibility.md` — names the principle that justifies Caddy's design: *agent suggestions are a depleting trust resource.* Generalizable doctrine for any advisory system.
  - `vault/concepts/The Self-Management Layer.md` — umbrella concept for the patterns that keep the framework coherent without manual maintenance. Members: Caddy, Self-Improving CLAUDE.md, Memory Decay, /diagnose, /system-check, /skill-audit, decision aging.
- **Caddy-supporting skills (preserve non-blocking constraint):**
  - `/caddy-explain` — walks Caddy's deterministic scoring on demand. Inspectability ↔ legibility thesis.
  - `/caddy-mute` — bounded-duration suppression for flow protection. Auto-restores; never permanent.
  - `/caddy-audit` — quarterly hygiene pass. Detects index/file drift (orphans in either direction, trigger staleness).

### Changed
- README hero — extended to surface the toolbox-manages-itself claim alongside the legibility thesis: "*An AI that operates on itself — and a toolbox that manages itself, on top of it.*"
- `vault/concepts/The Seven Layers.md` — added Caddy cross-layer footprint section (Caddy lives across L2/L3/L4/L6; cross-layer is a feature, not a bug).
- `skills/diagnose/SKILL.md` — Layer 2 check now includes `/caddy-explain` and `/caddy-audit` for Caddy-specific diagnostics.
- `.claude/skill-index.json` — added 3 new Caddy skills with rich Caddy-aggressive trigger keywords.

### Authority reasoning
All AL1 (doctrine + non-blocking skills + cross-references). No new behavior; no kernel changes; no breaking changes.

## [0.2.0] — 2026-04-26 — "The editorial release"

### Added
- **Manifesto + thesis:**
  - `docs/manifesto.md` — names the [[Legibility Thesis]] explicitly. AI memory belongs to the principal, in a format the principal can read.
  - README rewrite — new tagline "The personal operating system that operates itself"; new "How this repo maintains itself" section; Posture/bio-hacking section.
- **Doctrine drop (9 new concept notes):**
  - `Legibility Thesis.md` — the meta-doctrine
  - `The Two Roles.md` — principal-as-user vs maintainer
  - `Skills Graduation Curve.md` — phases at 5/15/30/50+ skills, why Caddy is essential
  - `Three Rules.md` — verify-before-claim, smallest-change, tell-the-truth (constitutional)
  - `Negative Space Discipline.md` — what disciplined agents refuse to do
  - `Bio-hacking Posture.md` — the principal tunes, doesn't consume
  - `What I Am Not Building.md` — explicit rejection list (template)
  - `Modern AI Infrastructure Stack.md` — reference map of where each layer sits
  - `The Seven Layers.md` — Titus's internal architecture (kernel → principal config)
- **Adoption skills (3):**
  - `/system-check` — audits install integrity
  - `/skill-audit` — flags dead skills, detects Caddy trigger mismatches
  - `/diagnose` — walks the seven-layer stack to identify failing layer
- **Agent-discipline skills (7, sourced from external playbook with attribution):**
  - `/envelope` — Ship / Ask one focused question / Propose
  - `/self-review` — spawn reviewer subagent with 4-6 specific verification questions
  - `/honesty-check` — volunteering ledger before declaring done
  - `/first-10-moves` — operational recon for unfamiliar codebases
  - `/stuck` — 6-rung escalation ladder
  - `/timeline-calibration` — self-correct timeline estimates from human-dev anchors
  - `/sandbox-routing` — self-correct tool choice for large outputs
- **Learning capture:**
  - `/learn` skill — captures evaluations as structured notes (ADOPT/HOLD/REJECT/MONITOR)
  - `vault/concepts/learning/INDEX.md` — auto-maintained index of all `/learn` captures
- **Measurement scaffolding:**
  - `vault/memory/DECISION_OUTCOMES.md` — outcome aging tracker for decisions logged in DECISION_LOG. 30/60/90-day check-in points. Data feed for `/retro` (forthcoming v0.3).
- **Security:**
  - `SECURITY.md` (root) — real disclosure policy. Uses GitHub native private vulnerability reporting (no email channel needed).
  - `docs/install-security.md` — trust model for the curl|bash one-liner. Four verification options.
- **Kernel changelog:**
  - `system/CHANGELOG.md` — separate audit trail for kernel changes (higher-stakes than skills/hooks).
- **Examples:**
  - `vault/examples/` — populated example notes showing what good vault content looks like.
  - `docs/first-session-walkthrough.md` — narrative walkthrough for new installs.
  - `vault/concepts/Common Anti-Patterns.md` — operating rules that prevent common agent failure modes.
  - `CONTRIBUTING.md` — contribution guide.
  - "Who this is for" + comparison sections in README.

### Changed
- "15 markdown files" → "15-document kernel + extended specs" throughout README and CLAUDE.md (matches reality; previously misrepresented).
- Model identifiers in routing tables — now explicitly noted as "latest in tier" rather than pinned versions; survives Anthropic version bumps.

## [0.1.0] — 2026-04-25

### Added
- Initial public release
- 15 system documents (`00_identity.md` → `14_decision_framework.md`)
- 5 extended system docs (`finance_agent.md`, `titus_operating_system.md`, `titus_delegation_map.md`, `titus_memory_and_continuity.md`, `titus_tools_and_plugins.md`)
- Hook scripts: auto-capture, session summary, token tracker, suggest-compact, security scan
- Skills: `/open`, `/close`, `/brief`, `/decide`, `/deep-recon`, `/semantic-search`, `/loop-lab`, `/caddy-enroll`
- Daemons: `caddy.sh`, `semantic-search/`, `memory-heat/compute-heat.js`
- Doctrine notes: Self-Improving CLAUDE.md, Caddy (initial), Memory Decay Doctrine, Feature Design Workflow, External Toolkit Learnings Pattern
- One-line install via `bash <(curl -s https://.../install.sh)`
- MIT license

[Unreleased]: https://github.com/wrg32786/titus-os/compare/v0.2.1...HEAD
[0.2.1]: https://github.com/wrg32786/titus-os/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/wrg32786/titus-os/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/wrg32786/titus-os/releases/tag/v0.1.0
