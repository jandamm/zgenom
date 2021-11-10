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
    # $ZGEN_INIT might delete itself when $ZGEN_RESET_ON_CHANGE is used.
    saved) [[ -f "${ZGEN_INIT}" ]] && source ${ZGEN_INIT} && [[ -f "${ZGEN_INIT}" ]];;
    *) __zgenom $@;;
    esac
}

function zgen() zgenom $@
typeset -a ZGENOM_EXTENSIONS
