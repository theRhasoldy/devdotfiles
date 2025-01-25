set fish_greeting ""

if status is-interactive
  pfetch
  zoxide init fish | source
  starship init fish | source
end
