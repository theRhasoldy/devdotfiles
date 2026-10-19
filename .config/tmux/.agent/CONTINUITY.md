# CONTINUITY

## PLAN
- Maintain custom tmux configuration.

## DECISIONS
- Disabled `C-k` navigation binding from `vim-tmux-navigator` by setting `@vim_navigator_mapping_up ""` and unbinding `C-k` in `tmux.conf`.

## PROGRESS
- Disabled `Ctrl+k` pane switching in [tmux.conf](file:///home/rhasoldy/.config/tmux/tmux.conf) and reloaded configuration in running tmux session.

## DISCOVERIES
- `vim-tmux-navigator` bound `C-k` in root and `copy-mode-vi` tables, which conflicted with terminal line-kill behavior.

## OUTCOMES
- `Ctrl+k` is no longer intercepted by tmux; shell line editing functions without conflict.
