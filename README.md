
> **ARCHIVED** — see [ARCHIVED.md](./ARCHIVED.md)

# cofiswarm-coordinator

Cofiswarm component: `coordinator`.

- Layout: [REPO-STANDARD-LAYOUT](https://github.com/keepdevops/cofiswarm-docs/blob/main/REPO-STANDARD-LAYOUT.md)
- Migration: [MIGRATION-SPRINTS](https://github.com/keepdevops/cofiswarm-docs/blob/main/MIGRATION-SPRINTS.md)

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
