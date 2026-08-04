# ==========================
# Fish basics
# ==========================

set -g fish_greeting


# ==========================
# Environment
# ==========================

set -gx EDITOR nvim
set -gx VISUAL nvim

set -gx BAT_THEME tokyonight_night

set -gx PATH $HOME/.local/bin $PATH


# ==========================
# Aliases
# ==========================

alias reload-fish="source ~/.config/fish/config.fish"
alias edit-fish="nvim ~/.config/fish/config.fish"

alias clear="clear -x"
alias cl="clear -x"

alias ls="eza --icons=auto"
alias ll="eza -lah --icons=auto"

alias python="python3"


# ==========================
# Zoxide
# ==========================

if command -q zoxide
    zoxide init fish | source
    alias cd="z"
end


# ==========================
# FZF
# ==========================

if command -q fzf
    set -gx FZF_DEFAULT_OPTS "
    --color=fg:#CBE0F0,
    bg:#011628,
    hl:#B388FF,
    fg+:#CBE0F0,
    bg+:#143652,
    hl+:#B388FF,
    info:#06BCE4,
    prompt:#2CF9ED,
    pointer:#2CF9ED,
    marker:#2CF9ED
    "
end


# ==========================
# Yazi
# ==========================

function y
    set tmp (mktemp -t yazi-cwd.XXXXXX)

    yazi $argv --cwd-file=$tmp

    if read -l cwd < $tmp
        if test -n "$cwd"; and test "$cwd" != "$PWD"
            cd $cwd
        end
    end

    rm -f $tmp
end


# ==========================
# Starship
# ==========================

if command -q starship
    starship init fish | source
end
