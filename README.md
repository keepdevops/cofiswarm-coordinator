# cofiswarm-coordinator

Cofiswarm component: `coordinator`.

- Layout: [REPO-STANDARD-LAYOUT](https://github.com/keepdevops/cofiswarmdev/blob/main/docs/REPO-STANDARD-LAYOUT.md)
- Migration: [MIGRATION-SPRINTS](https://github.com/keepdevops/cofiswarmdev/blob/main/docs/MIGRATION-SPRINTS.md)

## FHS paths

| Path | Purpose |
|------|---------|
| `/etc/cofiswarm/coordinator/` | config |
| `/var/lib/cofiswarm/coordinator/` | state |
| `/var/log/cofiswarm/coordinator/` | logs |

## Test

```bash
./test/scripts/assert-layout.sh coordinator
```
