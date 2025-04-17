set fish_greeting ""

starship init fish | source

if status is-interactive
  pfetch
  zoxide init fish | source
end

# tabtab source for packages
# uninstall by removing these lines
[ -f ~/.config/tabtab/__tabtab.fish ]; and . ~/.config/tabtab/__tabtab.fish; or true
