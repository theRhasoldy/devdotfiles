#ls --> exa
alias ls "exa --icons --group-directories-first"
alias lsa "ls -a"
alias ll "ls -l@ --git --time accessed --no-permissions"
alias lla "ll -a"
alias lld "ll -D"
alias llf "ll -f"
alias llt "lla -T"

# ...
alias ... "../.."
alias .... "../../.."
alias ..... "../../../.."
alias ...... "../../../../.."

# Convenient copy/remove/move
alias rm "rm -vI"
alias cp "rsync -ahv --info progress2"
alias mv "mv -vi"

# Nvim
alias vim "nvim"
alias vi "nvim"
alias nano "nvim" # Nano can suck deez nuts

alias rg "rg --sort path"

# Legacy
alias cat "bat"

# Git
alias g "git"
alias gs "git status"
alias ga "git add"
alias gc " git commit -m"

alias gcz "git cz"
alias glcz "git cz && gitleaks detect"

alias gps "git push"
alias glps "gitleaks detect && git push"

alias gpl "git pull"

# Dotfiles
alias dot "/usr/bin/git --git-dir $HOME/.config/dotfiles.git/ --work-tree $HOME"
alias dots "dot status --untracked-files no"
alias dota "dot add"
alias dotc "dot commit -m"
alias dotps "dot push"

# Dev Dotfiles
alias devdot "/usr/bin/git --git-dir $HOME/.config/devdotfiles.git/ --work-tree $HOME"
alias devdots "devdot status --untracked-files no"
alias devdota "devdot add"
alias devdotc "devdot commit -m"
alias devdotps "devdot push"

# Clean Pacman
alias pacclean "paru -Rns (paru -Qtdq)"

# ex = EXtractor for all kinds of archives
# usage: ex <file>
function ex
  if test -f $argv[1]
    switch $argv[1]
      case *.tar.bz2
        tar xjf $argv[1]
      case *.tar.gz
        tar xzf $argv[1]
      case *.bz2
        bunzip2 $argv[1]
      case *.rar
        unrar x $argv[1]
      case *.gz
        gunzip $argv[1]
      case *.tar
        tar xf $argv[1]
      case *.tbz2
        tar xjf $argv[1]
      case *.tgz
        tar xzf $argv[1]
      case *.zip
        unzip $argv[1]
      case *.Z
        uncompress $argv[1]
      case *.7z
        7z x $argv[1]
      case *.deb
        ar x $argv[1]
      case *.tar.xz
        tar xf $argv[1]
      case *.tar.zst
        tar xf $argv[1]
      case '*'
        echo "'$argv[1]' cannot be extracted via ex()"
    end
  else
    echo "'$argv[1]' is not a valid file"
  end
end

alias screenshare "xwaylandvideobridge"
