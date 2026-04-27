# Changelog

All notable changes to Titus OS are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

For changes to the kernel itself (the 15 numbered system documents and extended specs), see [`system/CHANGELOG.md`](system/CHANGELOG.md).

## [Unreleased]

(Pending changes for the next release land here.)

## [0.2.2] — 2026-04-27 — "Measurement primitives + adversarial doctrine"

Foundation for the v0.3 measurement release. Six original inventions ship as
doctrine + skills + scaffolds. None of them depend on v0.3 measurement skills
to be useful immediately; together they establish the data substrates that
v0.3 will build on.

### Added

**Adversarial doctrine (principal-side discipline):**
- `vault/concepts/Reading Agent Output Defensively.md` — companion to `/honesty-check`. Tells the principal how to spot when an agent didn't volunteer the truth. 10 patterns of confident-sounding bullshit + the standard push-back move.

**Cost of Confidence (longitudinal trust calibration):**
- `vault/concepts/Cost of Confidence.md` — names the pattern: every confident claim that turns out wrong is a trust-decay event.
- `skills/trust-decay/SKILL.md` — two-phase ledger skill. Phase 1 captures confident claims; Phase 2 resolves them as right or wrong. Pairing is the whole point.
- `vault/memory/TRUST_DECAY.md` — the ledger file (Open + Resolved sections; auto-managed).

**Common Failure Modes (institutional debugging memory):**
- `vault/concepts/Common Failure Modes.md` — names the pattern: every confirmed `/diagnose` outcome becomes Phase 1 corpus; recurring patterns graduate to Phase 2 doctrine.
- `vault/memory/FAILURE_MODES.md` — corpus file (Phase 1 entries + pattern frequency tracker).
- `skills/diagnose/SKILL.md` — extended with Step 6: write verified diagnosis outcomes to the corpus.

**Honesty Ledger (structured artifact, not just doctrine):**
- `vault/memory/HONESTY_LEDGER.md` — longitudinal record of `/honesty-check` outputs. Pairs to TRUST_DECAY.md when discrepancies surface.
- `skills/honesty-check/SKILL.md` — extended to also write a structured machine-readable entry per invocation. Resolution field updated by `/trust-decay resolve` later.

**Attention Reconciliation (drift detection at /open):**
- `vault/concepts/Attention Reconciliation.md` — the doctrine. Where you said you'd spend attention vs where you actually did, computed every session.
- `skills/open/SKILL.md` — extended with two new protocol steps:
  - Step 7: decision aging check (surfaces 30/60/90-day decisions awaiting outcome capture)
  - Step 8: attention reconciliation (compares last 7 days of daily notes to ACTIVE_PRIORITIES, flags drift > 20%)

**Promote (conversation → durable artifact):**
- `skills/promote/SKILL.md` — selective elevation skill. Take a slice of the current conversation and produce a vault concept / project / person / decision artifact. Pairs with `/close` (transient) by handling the durable layer.

**Caddy:**
- `.claude/skill-index.json` — added `/promote` and `/trust-decay` entries with rich triggers.

### Changed
- `/honesty-check` skill produces both human-readable summary AND machine-readable ledger entry per invocation.
- `/diagnose` skill writes Phase 1 corpus entries on verified diagnoses.
- `/open` skill protocol now includes decision aging + attention reconciliation steps before main orientation output.

### Authority reasoning
All AL1 (additive doctrine + auto-capture extensions to existing skills + scaffold files). No kernel changes; no breaking changes; all measurement layer is data-collection-only at this release. v0.3 will ship the analyzers (`/retro`, `/skill-economics`, `/quality-pulse`) that consume this data.

### What's NOT in this release (deferred to v0.3)
- `/retro` quarterly analysis skill — needs at least 30 days of TRUST_DECAY + HONESTY_LEDGER + FAILURE_MODES data
- `/skill-economics` — needs Caddy hint-followed tracking (Caddy improvement queued separately)
- `/quality-pulse` — Friday three-question survey skill
- Cadence enforcement hooks (D2 from v0.3 brief)
- `/missed-cadence` skill (D3)

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
