function fish_hybrid_key_bindings --description \
    "Vi-style bindings that inherit emacs-style bindings in all modes"
    for mode in default insert visual
        fish_default_key_bindings -M $mode
    end
    fish_vi_key_bindings --no-erase

    # Atuin: normal-mode `k` should open the history search like the up arrow.
    # Set as a user binding so it overrides the vi preset (up-or-search).
    if functions -q _atuin_bind_up
        bind -M default k _atuin_bind_up
    end
end

set -g fish_cursor_insert line
set -g fish_cursor_default block

if status is-interactive
    if string match -q -- 'tmux*' $TERM
        set -g fish_vi_force_cursor 1
    end
    set -g fish_key_bindings fish_hybrid_key_bindings
end
