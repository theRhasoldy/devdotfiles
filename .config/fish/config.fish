set fish_greeting ""

starship init fish | source

if status is-interactive
  pfetch
  zoxide init fish | source

  if not set -q SSH_AUTH_SOCK
      eval (ssh-agent -c)
  end
end

# tabtab source for packages
# uninstall by removing these lines
[ -f ~/.config/tabtab/__tabtab.fish ]; and . ~/.config/tabtab/__tabtab.fish; or true
