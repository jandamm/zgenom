# Zsh Plugin Standard
if [[ $ZGENOM_AUTO_ADD_BIN -eq 1 ]]; then
    export PMSPEC=0fbiPs
else
    export PMSPEC=0fiPs
    ZGENOM_AUTO_ADD_BIN=0
fi
if [[ -z $ZPFX ]]; then
    export ZPFX="$ZGEN_SOURCE/polaris"
fi

if [[ -z "${ZGENOM_SOURCE_BIN}" ]]; then
    ZGENOM_SOURCE_BIN="$ZGEN_SOURCE/bin"
fi

# The user can explicitly disable Zgenom attempting to invoke `compinit`, or it
# will be automatically disabled if `compinit` appears to have already been
# invoked.
if [[ -z "${ZGEN_AUTOLOAD_COMPINIT}" && -z "${(t)_comps}" ]]; then
    ZGEN_AUTOLOAD_COMPINIT=1
fi

: ${(q)ZGEN_CUSTOM_COMPDUMP:=$ZGEN_DIR/zcompdump_$ZSH_VERSION}
if [[ -n "${ZGEN_CUSTOM_COMPDUMP}" ]]; then
    ZGEN_COMPINIT_DIR_FLAG="-d ${(q)ZGEN_CUSTOM_COMPDUMP}"
    ZGEN_COMPINIT_FLAGS="${ZGEN_COMPINIT_DIR_FLAG} ${ZGEN_COMPINIT_FLAGS}"
fi

if [[ -z "${ZGEN_LOADED}" ]]; then
    ZGEN_LOADED=()
fi

if [[ -z "${ZGENOM_LOADED}" ]]; then
    ZGENOM_LOADED=()
fi

if [[ -z "${ZGENOM_PLUGINS}" ]]; then
    ZGENOM_PLUGINS=()
fi

if [[ -z "${ZGENOM_INIT_BUILDER}" ]]; then
    ZGENOM_INIT_BUILDER=""
fi

if [[ -z "${zsh_loaded_plugins}" ]]; then
    typeset -ga zsh_loaded_plugins
fi

if [[ -z "${ZGEN_PREZTO_OPTIONS}" ]]; then
    ZGEN_PREZTO_OPTIONS=()
fi

if [[ -z "${ZGEN_PREZTO_LOAD}" ]]; then
    ZGEN_PREZTO_LOAD=()
fi

if [[ -z "${ZGEN_COMPLETIONS}" ]]; then
    ZGEN_COMPLETIONS=()
fi

if [[ -z "${ZGEN_USE_PREZTO}" ]]; then
    ZGEN_USE_PREZTO=0
fi

if [[ -z "${ZGEN_PREZTO_LOAD_DEFAULT}" ]]; then
    ZGEN_PREZTO_LOAD_DEFAULT=1
fi

if [[ -z "${ZGEN_OH_MY_ZSH_REPO}" ]]; then
    ZGEN_OH_MY_ZSH_REPO=ohmyzsh/ohmyzsh
fi

if [[ "${ZGEN_OH_MY_ZSH_REPO}" != */* ]]; then
    # Even though the default repo is now ohmyzsh most forks still use oh-my-zsh
    ZGEN_OH_MY_ZSH_REPO="${ZGEN_OH_MY_ZSH_REPO}/oh-my-zsh"
fi

if [[ -z "${ZGEN_PREZTO_REPO}" ]]; then
    ZGEN_PREZTO_REPO=sorin-ionescu
fi

if [[ "${ZGEN_PREZTO_REPO}" != */* ]]; then
    ZGEN_PREZTO_REPO="${ZGEN_PREZTO_REPO}/prezto"
fi

