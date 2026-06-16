# ARCHIVED — bridge component (Sprint 14)

This repo held the C++ **coordinator** during the monorepo → 43-repo migration.

**Replacement**

| Was | Now |
|-----|-----|
| Coordinator routes | `cofiswarm-dispatch`, `cofiswarm-agent-registry`, mode repos |
| Proxy configure/spawn | `cofiswarm-deploy` `stack-up.sh` + `cofiswarm-launcher` |
| `/api/pressure` | `cofiswarm-slot-manager` :8013 |

Read-only reference. Do not deploy for new installs after `v3.0.0-bridge`.
