set fish_greeting ""

if status is-interactive
  zoxide init fish | source
  starship init fish | source
end
