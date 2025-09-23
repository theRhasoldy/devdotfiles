# XDG Environment Variables
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_CACHE_HOME "$HOME/.cache"
set -gx XDG_STATE_HOME "$HOME/.local/state"
set -gx XDG_DATA_DIRS "/usr/local/share:/usr/share"

# Language Settings
  set -gx LANG 'en_US.UTF-8'
  set -gx LANGUAGE 'en_US.UTF-8'

set -gx VIMCONFIG "$XDG_CONFIG_HOME/nvim"
set -gx VIMRUNTIME "/usr/share/nvim/runtime"

# Defaults
set -gx TERM xterm-256color

set -gx EDITOR nvim
set -gx VISUAL nvim

set -gx PAGER moor
set -gx MANPAGER moor
set -gx MOOR "--statusbar=bold --style=base16-snazzy"
set -gx QT_STYLE_OVERRIDE kvantum

# Locales
set -gx LC_COLLATE en_US.UTF-8
set -gx LC_CTYPE en_US.UTF-8
set -gx LC_MESSAGES en_US.UTF-8
set -gx LC_MONETARY en_US.UTF-8
set -gx LC_NUMERIC en_US.UTF-8
set -gx LC_TIME en_US.UTF-8
set -gx LC_ALL en_US.UTF-8
set -gx LESSCHARSET utf-8

# Env
set -gx PNPM_HOME "$HOME/.local/share/pnpm"
set -gx WINEPREFIX "$XDG_DATA_HOME/wine"

if not contains -- "$PNPM_HOME" $PATH
  set -gx PATH $PNPM_HOME $PATH
end

set -gx GTK2_RC_FILES "$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
set -gx XCURSOR_PATH "/usr/share/icons" "$XDG_DATA_HOME/icons"
set -gx _JAVA_OPTIONS "-Djava.util.prefs.userRoot=$XDG_CONFIG_HOME/java"

# FUCK Gradle
set -gx GRADLE_USER_HOME "$XDG_DATA_HOME/gradle"

set -gx GOPATH "$XDG_DATA_HOME/go"
set -gx GNUPGHOME "$XDG_DATA_HOME/gnupg"

# Rust
set -gx RUSTUP_HOME "$XDG_DATA_HOME/rustup"
set -gx CARGO_HOME "$XDG_DATA_HOME/cargo"

# w3m
set -gx W3M_DIR "$XDG_CACHE_HOME/w3m"

# Zsh search path for executable
set -gx path /usr/local/bin /usr/local/sbin $path

# Add all scripts in scripts/ executable
set -gx PATH "$XDG_CONFIG_HOME/scripts" $PATH
set -gx PATH "$GOPATH/bin" $PATH

# Add all npm packages to the path
set -gx PATH "$XDG_DATA_HOME/npm/bin" $PATH

# Bfetch
set -gx BFETCH_CLASSIC_MODE true 

# Zoxide
set -gx _ZO_ECHO 1

# FZF
set -gx FZF_DEFAULT_COMMAND "fd --hidden --strip-cwd-prefix --exclude .git"

# FZF FISH
set -gx fzf_preview_dir_cmd "exa --icons --group-directories-first -l@ --git --time accessed --no-permissions"
set -gx fzf_diff_highlighter "delta --paging=never"

# QT
set -gx QT_QPA_PLATFORMTHEME "qt5ct"

set -gx GEMINI_API_KEY (sed -n '/^key =/s/.*key = //p' $XDG_CONFIG_HOME/geminicommit/config.toml | sed "s/'//g")

# npm
set -gx NPM_CONFIG_USERCONFIG $XDG_CONFIG_HOME/npm/npmrc
set -gx NPM_CONFIG_INIT_MODULE "$XDG_CONFIG_HOME"/npm/config/npm-init.js
set -gx NPM_CONFIG_CACHE "$XDG_CACHE_HOME"/npm
set -gx NPM_CONFIG_TMP "$XDG_RUNTIME_DIR"/npm
