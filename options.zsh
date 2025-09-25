# Zsh Plugin Standard (nounset-safe)
if (( ${ZGENOM_AUTO_ADD_BIN:-0} == 1 )); then
    export PMSPEC=0fbiPs
else
    export PMSPEC=0fiPs
    ZGENOM_AUTO_ADD_BIN=0
fi

# Provide defaults without tripping on unset variables
if [[ -z ${ZPFX-} && -n ${ZGEN_SOURCE-} ]]; then
    export ZPFX="${ZGEN_SOURCE}/polaris"
fi

if [[ -z ${ZGENOM_SOURCE_BIN-} && -n ${ZGEN_SOURCE-} ]]; then
    ZGENOM_SOURCE_BIN="${ZGEN_SOURCE}/bin"
fi

# The user can explicitly disable Zgenom attempting to invoke `compinit`, or it
# will be automatically disabled if it appears to have already been invoked.
if (( ${+ZGEN_AUTOLOAD_COMPINIT} == 0 )) && (( ${+_comps} == 0 )); then
    ZGEN_AUTOLOAD_COMPINIT=1
fi

# Custom compdump path; guard references
if (( ${+ZGEN_CUSTOM_COMPDUMP} == 0 )) && (( ${+ZGEN_DIR} )); then
    ZGEN_CUSTOM_COMPDUMP="${ZGEN_DIR}/zcompdump_${ZSH_VERSION}"
fi
if [[ -n ${ZGEN_CUSTOM_COMPDUMP-} ]]; then
    ZGEN_COMPINIT_DIR_FLAG="-d ${(q)ZGEN_CUSTOM_COMPDUMP}"
    ZGEN_COMPINIT_FLAGS="${ZGEN_COMPINIT_DIR_FLAG} ${ZGEN_COMPINIT_FLAGS-}"
fi

# Ensure arrays/scalars exist without expanding unset variables
: ${ZGEN_LOADED:=()}
: ${ZGENOM_LOADED:=()}
: ${ZGENOM_PLUGINS:=()}
(( ${+zsh_loaded_plugins} )) || typeset -ga zsh_loaded_plugins
: ${ZGEN_PREZTO_OPTIONS:=()}
: ${ZGEN_PREZTO_LOAD:=()}
: ${ZGEN_COMPLETIONS:=()}
: ${ZGEN_USE_PREZTO:=0}
: ${ZGEN_PREZTO_LOAD_DEFAULT:=1}
: ${ZGEN_OH_MY_ZSH_REPO:=ohmyzsh/ohmyzsh}

if [[ ${ZGEN_OH_MY_ZSH_REPO-} != */* ]]; then
    # Even though the default repo is now ohmyzsh most forks still use oh-my-zsh
    ZGEN_OH_MY_ZSH_REPO="${ZGEN_OH_MY_ZSH_REPO}/oh-my-zsh"
fi

: ${ZGEN_PREZTO_REPO:=sorin-ionescu}
if [[ ${ZGEN_PREZTO_REPO-} != */* ]]; then
    ZGEN_PREZTO_REPO="${ZGEN_PREZTO_REPO}/prezto"
fi
