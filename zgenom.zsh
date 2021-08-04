ZGEN_SOURCE="$0:A:h"

if [[ -z "${ZGEN_DIR}" ]]; then
    if [[ -e "${HOME}/.zgen" ]]; then
        ZGEN_DIR="${HOME}/.zgen"
    else
        ZGEN_DIR="$ZGEN_SOURCE/sources"
    fi
fi

ZGEN_INIT=${ZGEN_INIT:-${ZGEN_DIR}/init.zsh}

fpath=($ZGEN_SOURCE/functions $fpath)

autoload -Uz __zgenom
autoload -Uz __zgenom_out
autoload -Uz __zgenom_err
autoload -Uz zgenom-autoupdate
function zgenom() {
    case $1 in
    autoupdate) shift; zgenom-autoupdate $@;;
    init) zgenom saved || return 0;;
    saved) [[ -f "${ZGEN_INIT}" ]] && source ${ZGEN_INIT};;
    *) __zgenom $@;;
    esac
}

alias zgen=zgenom
