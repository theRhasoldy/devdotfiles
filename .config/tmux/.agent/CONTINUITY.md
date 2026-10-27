# CONTINUITY

## PLAN
- Maintain custom tmux configuration.

## DECISIONS
- Disabled `C-k` navigation binding from `vim-tmux-navigator` by setting `@vim_navigator_mapping_up ""` and unbinding `C-k` in `tmux.conf`.
- Attention highlighting uses tmux's built-in activity/bell flags (`monitor-activity on`, `monitor-bell on`); OSC notifications keep going to the outer terminal via passthrough rather than driving tmux state.
- A window needs attention only when `window_activity_flag && window_silence_flag` (`monitor-silence 5`): output since the last visit *and* 5s of quiet. Activity alone flagged agent TUIs constantly, since they stream output while working.
- Because tmux applies `window-status-activity-style` on activity **or** silence, that option is set to `default` and the red style is applied inline by the window format; bells keep their own `window-status-bell-style` (immediate, no silence gate).
- Attention tabs are text-only: `fg=#d1766e` + `bold` via inline `#[...]` (cendre red on the status background); no fill.
- No dot/glyph indicator anywhere: `status-left` is empty and tabs carry no marker. Attention is signalled only by the tab's red bold text, in the current session (other sessions' windows have no tab to colour).
- Noise is excluded from attention via `@attention_ignore`, a regex matched against `pane_current_command`: dev servers/watchers (npm/pnpm/yarn/bun/deno/node/vite/next/webpack/python/uvicorn/rails/java/docker/postgres/redis/nginx/…), full-screen apps that redraw on focus (nvim/vim/less/man/htop/top), and shells (fish/bash/zsh/sh/…). Ignored panes get neither a dot nor red text, for bells as well as activity, so dots and tabs always agree.
- Ignoring shells means a finished command in a shell pane never lights up; drop `fish|bash|zsh|sh` from `@attention_ignore` to opt back in.
- Explicit hex over color names because Ghostty theme `cendre` maps `white` to `#a09384` (unreadable) and `red` to `#d1766e`.

## PROGRESS
- Disabled `Ctrl+k` pane switching in [tmux.conf](file:///home/rhasoldy/.config/tmux/tmux.conf) and reloaded configuration in running tmux session.
- Added `# Attention` block and red activity/bell tab styles to [tmux.conf](file:///home/rhasoldy/.config/tmux/tmux.conf); sourced config, settings verified live.

## DISCOVERIES
- `vim-tmux-navigator` bound `C-k` in root and `copy-mode-vi` tables, which conflicted with terminal line-kill behavior.
- Activity/bell flags only clear on window selection while a client is attached (verified on tmux 3.8); detached sessions retain flags.
- `send-keys` echo into a background pane counts as activity, so typing in a hidden window lights it up.
- `session_alerts` is session-scoped; the `#{S:…}` modifier rebinds session context per session, and `W:` iterates that session's windows, so `#{S:#{W:…}}` can aggregate over every window server-wide.
- A comma inside `#[…]` splits the arguments of an enclosing `#{?cond,true,false}`: emit `#[fg=yellow]#[nobold]` rather than `#[fg=yellow,nobold]`.
- nvim flags itself on every focus change: with `focus-events on`, switching away makes it redraw, and any pane write counts as activity. Idle fish does not self-flag, but accepting a prompt (Enter, new window, command finishing) writes output, so shells nag constantly.
- OSC 9 and OSC 777 do not set any tmux flag (tested on 3.8); only a real BEL does. Agent TUI notifications therefore reach Ghostty through passthrough but never light tmux.
- Silence gating degrades gracefully: a TUI that animates while waiting (spinner/elapsed timer) never goes silent, so it never flags.

## OUTCOMES
- `Ctrl+k` is no longer intercepted by tmux; shell line editing functions without conflict.
- Background windows with new output or a BEL turn red in the status bar until visited.
- Dev servers (`npm run dev`, `python -m http.server`, …) can chatter in the background without lighting a tab or a dot.
- An agent that stops producing output for 5s lights its tab; one that is still streaming does not. Verified live: streaming `agy` stayed dark while idle `opencode` lit up.
