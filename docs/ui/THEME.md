# Theme Notes (Phase 2A)

## Storage Key
- `rh-theme`

## Theme Decision Order
1. `localStorage.getItem('rh-theme')`
2. `prefers-color-scheme: dark` (if true -> `dark`)
3. fallback -> `light`

## Token Map
| Variable | Role | Light Value | Dark Value |
|---|---|---|---|
| `--txt` | Body text color | `#1f2735` | `#f7f9ff` |
| `--dim` | Secondary text color | `#3b465a` | `#d7e0f4` |
| `--bdr` | Standard border color | `#ccd6ea` | `#344262` |
| `--bdr2` | Emphasis border color | `#b8c5df` | `#4a5e89` |
| `--link` | Link color | `#7c1f57` | `var(--acc2)` |
| `--link-hover` | Link hover color | `#a32772` | `var(--acc)` |
| `--heading` | Heading color | `#c52f80` | `var(--acc)` |
| `--hero-mark` | Hero shield/icon mark color | `rgba(31,39,53,.26)` | `rgba(240,246,255,.28)` |
| `--hero-mark-opacity` | Hero shield/icon opacity | `.5` | `.5` |

## Acceptance Checklist
- [ ] No FOUC on hard refresh.
- [ ] Toggle persists across refresh.
- [ ] Contrast: body text readable in both themes.
- [ ] Links readable in both themes.
- [ ] Hero mark visible but subtle in both themes.

## Reset for Testing
- Browser DevTools console:
  - `localStorage.removeItem('rh-theme')`
  - then hard refresh.
