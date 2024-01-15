# XDG Environment Variables
if test -z "$XDG_CONFIG_HOME"
    set -gx XDG_CONFIG_HOME "$HOME/.config"
end

if test -z "$XDG_DATA_HOME"
    set -gx XDG_DATA_HOME "$HOME/.local/share"
end

if test -z "$XDG_CACHE_HOME"
    set -gx XDG_CACHE_HOME "$HOME/.cache"
end

if test -z "$XDG_STATE_HOME"
    set -gx XDG_STATE_HOME "$HOME/.local/state"
end

# Language Settings
if test -z "$LANG"
  set -gx LANG 'en_US.UTF-8'
  set -gx LANGUAGE 'en_US.UTF-8'
end

set -gx VIMCONFIG "$XDG_CONFIG_HOME/nvim"
set -gx VIMRUNTIME "/usr/share/nvim/runtime"

# Defaults
set -gx TERM xterm-kitty

set -gx EDITOR nvim
set -gx VISUAL nvim

set -gx PAGER moar
set -gx MANPAGER moar
set -gx MOAR "--statusbar=bold --style=doom-one"
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
set -gx NPM_CONFIG_USERCONFIG $XDG_CONFIG_HOME/npm/npmrc
set -gx CARGO_HOME "$XDG_DATA_HOME/cargo"
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

# Zsh search path for executable
set -gx path /usr/local/bin /usr/local/sbin $path

# t
set -gx PATH "$HOME/.config/tmux/plugins/t-smart-tmux-session-manager/bin" $PATH

# Add all scripts in scripts/ executable
set -gx PATH "$XDG_CONFIG_HOME/scripts" $PATH
