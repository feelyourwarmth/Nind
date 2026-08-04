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

alias vencord='sh -c "$(curl -sS https://vencord.dev/install.sh)"'
alias mtx='unimatrix -n -a -l k'

alias clear="clear -x"
alias cl="clear -x"

alias ls="eza --icons=auto"
alias ll="eza -lah --icons=auto"

alias python="python3"

# git add .
function gt
    git add .
end

# git commit -m "mensagem"
function gtc
    git commit -m "$argv"
end

# git push -u origin main
function gtp
    git push -u origin main
end


# ==========================
# Zoxide
# ==========================

if command -q zoxide
    zoxide init fish | source
    alias cd="z"
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
