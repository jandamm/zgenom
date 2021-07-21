#!/bin/zsh
# vim: set ft=zsh fenc=utf-8 noai ts=4 et sts=4 sw=4 tw=80 nowrap :
local ZGEN_SOURCE="$0:A:h"

if [[ -z "${ZGEN_DIR}" ]]; then
    if [[ -e "${HOME}/.zgen" ]]; then
        ZGEN_DIR="${HOME}/.zgen"
    else
        ZGEN_DIR="$ZGEN_SOURCE/sources"
    fi
fi

if [[ -z "${ZGEN_INIT}" ]]; then
    ZGEN_INIT="${ZGEN_DIR}/init.zsh"
fi

if [[ -z $ZGENOM_ZGEN_COMPAT ]]; then
    ZGENOM_ZGEN_COMPAT=1
fi

zgen-saved() {
    if [[ -f "${ZGEN_INIT}" ]]; then
        zgen-init
    else
        return 1
    fi
}

zgen-init() {
    if [[ -f "${ZGEN_INIT}" ]]; then
        source "${ZGEN_INIT}"
    fi
}

zgen-autoupdate() {
    autoload -Uz zgenom-autoupdate
    zgenom-autoupdate $@
}

# Run initialization only once
if [[ -z $ZGENOM_LAZY_LOCK ]]; then
    zgenom() {
        case $1 in
            saved) zgen-saved;;
            init) zgen-init;;
            autoupdate)
                shift
                zgen-autoupdate $@
                ;;
            *)
                ZGENOM_LAZY_LOCK=yes
                source "${ZGEN_SOURCE}/zgen.zsh"
                unset ZGENOM_LAZY_LOCK
                zgenom $@
                ;;
        esac
    }
fi

fpath=($ZGEN_SOURCE/functions $fpath)

if [[ $ZGENOM_ZGEN_COMPAT -eq 1 ]]; then
    # Creating an alias wouldn't work when scripting like this:
    # zsh -c ".../zgen.zsh && zgen update"
    zgen() { zgenom $@ }
fi
