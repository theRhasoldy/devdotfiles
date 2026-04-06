set fish_greeting ""

if status is-interactive
    pfetch
    starship init fish | source
    zoxide init fish | source
end
