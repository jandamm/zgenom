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

zgen-saved() {
    [[ -f "${ZGEN_INIT}" ]] && return 0 || return 1
}

zgen-init() {
    if [[ -f "${ZGEN_INIT}" ]]; then
        source "${ZGEN_INIT}"
    fi
}

# Run initialization only once
if [[ -z $ZGENOM_LAZY_LOCK ]]; then
    zgenom() {
        case $1 in
            saved) zgen-saved;;
            init) zgen-init;;
            *)
                ZGENOM_LAZY_LOCK=yes
                source "${ZGEN_SOURCE}/zgen.zsh"
                unset ZGENOM_LAZY_LOCK
                zgenom $@
                ;;
        esac
    }
fi

fpath=($ZGEN_SOURCE $fpath)
zgen-init

# Creating an alias wouldn't work when scripting like this:
# zsh -c ".../zgen.zsh && zgen update"
zgen() { zgenom $@ }
