# Changelog

All notable changes to Titus OS are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- Sample session transcript in README
- `vault/examples/` — populated example notes showing what good vault content looks like
- `docs/first-session-walkthrough.md` — narrative walkthrough for new installs
- `vault/concepts/Common Anti-Patterns.md` — operating rules that prevent common agent failure modes
- `CONTRIBUTING.md` — contribution guide
- "Who this is for" + comparison sections in README

## [0.1.0] — 2026-04-25

### Added
- Initial public release
- 15 system documents (`00_identity.md` → `14_decision_framework.md`)
- 5 extended system docs (`finance_agent.md`, `titus_operating_system.md`, `titus_delegation_map.md`, `titus_memory_and_continuity.md`, `titus_tools_and_plugins.md`)
- Hook scripts: auto-capture, session summary, token tracker, suggest-compact, security scan
- Skills: `/open`, `/close`, `/brief`, `/decide`, `/deep-recon`, `/semantic-search`, `/loop-lab`, `/caddy-enroll`
- Daemons: `caddy.sh`, `semantic-search/`, `memory-heat/compute-heat.js`
- Doctrine notes: Self-Improving CLAUDE.md, Caddy, Memory Decay Doctrine, Feature Design Workflow, External Toolkit Learnings Pattern
- One-line install via `bash <(curl -s https://.../install.sh)`
- MIT license

[Unreleased]: https://github.com/wrg32786/titus-os/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/wrg32786/titus-os/releases/tag/v0.1.0
