#!/bin/zsh
# vim: set ft=zsh fenc=utf-8 noai ts=4 et sts=4 sw=4 tw=80 nowrap :
local ZGEN_SOURCE="$0:A:h"

-zgputs() { printf %s\\n "$@" ;}
-zgpute() { printf %s\\n "-- zgenom: $*" >&2 ;}

-zginit() { -zgputs "$*" >> "${ZGEN_INIT}" ;}

# Source zgen-lazy.zsh only once
if [[ -z $ZGENOM_LAZY_LOCK ]]; then
    ZGENOM_LAZY_LOCK=yes
    source $ZGEN_SOURCE/zgenom.zsh
    unset ZGENOM_LAZY_LOCK
fi

# The user can explicitly disable Zgen attempting to invoke `compinit`, or it
# will be automatically disabled if `compinit` appears to have already been
# invoked.
if [[ -z "${ZGEN_AUTOLOAD_COMPINIT}" && -z "${(t)_comps}" ]]; then
    ZGEN_AUTOLOAD_COMPINIT=1
fi

if [[ -n "${ZGEN_CUSTOM_COMPDUMP}" ]]; then
    ZGEN_COMPINIT_DIR_FLAG="-d ${(q)ZGEN_CUSTOM_COMPDUMP}"
    ZGEN_COMPINIT_FLAGS="${ZGEN_COMPINIT_DIR_FLAG} ${ZGEN_COMPINIT_FLAGS}"
fi

if [[ -z "${ZGEN_LOADED}" ]]; then
    ZGEN_LOADED=()
fi

if [[ -z "${ZGENOM_ADD_PATH}" ]]; then
    ZGENOM_ADD_PATH=1
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

-zgen-encode-url () {
    # Remove characters from a url that don't work well in a filename.
    # Inspired by -anti-get-clone-dir() method from antigen.
    local url="${1}"
    url="${url//\//-SLASH-}"
    url="${url//\:/-COLON-}"
    url="${url//\|/-PIPE-}"
    url="${url//~/-TILDE-}"
    -zgputs "$url"
}

-zgen-get-clone-dir() {
    local repo="${1}"
    local branch="${2:-___}"

    if [[ -e "${repo}/.git" ]]; then
        -zgputs "${ZGEN_DIR}/local/${repo:t}-${branch}"
    else
        # Repo directory will be location/reponame
        local reponame="${repo:t}"
        # Need to encode incase it is a full url with characters that don't
        # work well in a filename.
        local location="$(-zgen-encode-url ${repo:h})"
        repo="${location}/${reponame}"
        -zgputs "${ZGEN_DIR}/${repo}-${branch}"
    fi
}

-zgen-get-clone-url() {
    local repo="${1}"

    if [[ -e "${repo}/.git" ]]; then
        -zgputs "${repo}"
    else
        # Sourced from antigen url resolution logic.
        # https://github.com/zsh-users/antigen/blob/master/antigen.zsh
        # Expand short github url syntax: `username/reponame`.
        if [[ $repo != git://* &&
              $repo != https://* &&
              $repo != http://* &&
              $repo != ssh://* &&
              $repo != git@*:*/*
              ]]; then
            repo="https://github.com/${repo%.git}.git"
        fi
        -zgputs "${repo}"
    fi
}

zgen-clone() {
    local repo="${1}"
    local submodules='--recursive'
    if [[ $2 = '--no-submodules' ]]; then
        submodules=''
        shift
    elif [[ $3 = '--no-submodules' ]]; then
        submodules=''
    fi
    local branch="${2}"
    local url="$(-zgen-get-clone-url ${repo})"
    local dir="$(-zgen-get-clone-dir ${repo} ${branch})"

    if [[ -d "${dir}" ]]; then
        return # Everything is fine!
    elif [[ -z "$branch" ]] && [[ -d "${dir%-___}-master" ]]; then
        if [[ -z "$ZGENOM_MIGRATE_ALL" ]]; then
            -zgputs "When you don't specify a branch with zgenom, instead of using 'master' the git default branch is used."
            -zgputs "Do you want to migrate '${${dir#$ZGEN_DIR/}%-___}-master' to use the default branch?"
            -zgputs "If you say no, the repo will be cloned again. If you say quit, zgenom will be stopped."
            read "answer?(y/n/a/q): "
        else
            answer='y'
        fi
        case $answer in
            [Yy]) command mv "${dir%-___}-master" "$dir" ;;
            [Aa]) ZGENOM_MIGRATE_ALL="Y" && command mv "${dir%-___}-master" "$dir" ;;
            [Nn]) zgen-clone "$repo" '___' "${submodules:---no-submodules}" ;;
            *)    kill -s SIGINT $! ;;
        esac
    else
        mkdir -p "${dir}"
        if [[ -n "$branch" ]] && [[ ! "$branch" = '___' ]]; then
            eval "git clone --depth=1 $submodules -b $branch $url $dir"
        else
            eval "git clone --depth=1 $submodules $url $dir"
        fi
    fi
}

-zgen-add-to-fpath() {
    local completion_path="${1}"

    # Add the directory to ZGEN_COMPLETIONS array if not present
    if [[ ! "${ZGEN_COMPLETIONS[@]}" =~ ${completion_path} ]]; then
        ZGEN_COMPLETIONS+=("${completion_path}")
    fi
}

-zgen-source() {
    local file="${1}"

    if [[ ! "${ZGEN_LOADED[@]}" =~ "${file}" ]]; then
        ZGEN_LOADED+=("${file}")
        source "${file}"

        completion_path="${file:h}"

        -zgen-add-to-fpath "${completion_path}"
    fi
}

-zgen-prezto-option(){
    local module=${1}
    shift
    local option=${1}
    shift
    local params
    params=${@}
    if [[ ${module} =~ "^:" ]]; then
        module=${module[1,]}
    fi
    if [[ ! $module =~ "^(\*|module|prezto:module):" ]]; then
        module="module:$module"
    fi
    if [[ ! $module =~ "^(prezto):" ]]; then
        module="prezto:$module"
    fi
    local cmd="zstyle ':${module}' $option ${params}"

    # execute in place
    eval $cmd

    if [[ ! "${ZGEN_PREZTO_OPTIONS[@]}" =~ "${cmd}" ]]; then
        ZGEN_PREZTO_OPTIONS+=("${cmd}")
    fi
}

-zgen-prezto-load(){
    local params="$*"
    local cmd="pmodload ${params[@]}"

    # execute in place
    eval $cmd

    if [[ ! "${ZGEN_PREZTO[@]}" =~ "${cmd}" ]]; then
        ZGEN_PREZTO_LOAD+=("${params[@]}")
    fi
}

zgen-reset() {
    -zgpute 'Deleting `'"${ZGEN_INIT}"'` ...'
    if [[ -f "${ZGEN_INIT}" ]]; then
        rm "${ZGEN_INIT}"
    fi
    if [[ -f "${ZGEN_CUSTOM_COMPDUMP}" ]] || [[ -d "${ZGEN_CUSTOM_COMPDUMP}" ]]; then
        -zgpute 'Deleting `'"${ZGEN_CUSTOM_COMPDUMP}"'` ...'
        rm -r "${ZGEN_CUSTOM_COMPDUMP}"
    fi
    if [[ -d $(-zgen-bin-dir) ]]; then
        -zgpute 'Deleting `'"$(-zgen-bin-dir)"'` ...'
        rm -dr $(-zgen-bin-dir)
    fi
}

-zgen-git-fetch-head() {
    local result
    local branch
    if ! result=$(git remote set-head origin --auto 2>&1); then
        branch="${result#*refs/remotes/origin/}"
        [[ $result = $branch ]] && return 1
        branch="${branch% *}"
        git config remote.origin.fetch +refs/heads/"$branch":refs/remotes/origin/"$branch"  # Update config to point to new head
        git fetch --depth=1 origin                                                          # Fetch the new head
        git remote set-head origin --auto &>/dev/null                                       # Retry setting the new head
        return $?
    fi
}

-zgen-git-pull() {
    if [[ ! "$repo" =~ '-___$' ]]; then
        git pull --ff-only
    else
        local head
        if -zgen-git-fetch-head && head=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null); then
            local branch="${head#refs/remotes/origin/}"
            if [[ "$branch" = "$head" ]]; then
                -zgen-git-pull-fatal
                return
            fi

            local curbranch="$(git rev-parse --abbrev-ref HEAD)"
            if [[ "$branch" = "$curbranch" ]]; then
                # Current head is current branch.
                git pull --ff-only
            else
                -zgputs
                -zgputs "New default branch: '$branch'."
                git branch --quiet -D "$branch" &>/dev/null             # delete existing new head
                git checkout --quiet -b "$branch" "$head"               # checkout new head from origin
                git branch --quiet -D "$curbranch"                      # delete old local branch
                git branch --quiet --remotes -d "origin/$curbranch"     # delete old origin branch
            fi
        else
            -zgen-git-pull-fatal
        fi
    fi
}

-zgen-git-pull-fatal() {
    -zgpute
    -zgpute "Could not find default branch."
    -zgpute "Please delete the repos folder and let zgenom clone it again."
    -zgpute
}

zgen-update() {
    setopt localoptions extended_glob nullglob
    for repo in "${ZGEN_DIR}"/(^.git)/*; do
        [[ "${repo}" =~ $ZGEN_DIR/_/* ]] && continue
        -zgpute "Updating '${repo}' ..."
        (cd "${repo}" \
            && -zgen-git-pull \
            && git submodule update --recursive)
    done
    zgen-reset
}

zgen-save() {
    -zgpute 'Creating `'"${ZGEN_INIT}"'` ...'

    -zgputs "# {{{" >! "${ZGEN_INIT}"
    -zginit "# Generated by zgenom."
    -zginit "# This file will be overwritten the next time you run zgenom save!"
    -zginit ""
    -zginit "ZSH=$(-zgen-get-zsh)"
    if [[ ${ZGEN_USE_PREZTO} == 1 ]]; then
        -zginit ""
        -zginit "# ### Prezto initialization"
        for option in "${ZGEN_PREZTO_OPTIONS[@]}"; do
            -zginit "${option}"
        done
    fi

    -zginit ""
    -zginit "# ### General modules"
    for file in "${ZGEN_LOADED[@]}"; do
        -zginit 'source "'"${(q)file}"\"
    done

    # Set up fpath, load completions
    # NOTE: This *intentionally* doesn't use ${ZGEN_COMPINIT_FLAGS}; the only
    #       available flags are meaningless in the presence of `-C`.
    -zginit ""
    -zginit "# ### Plugins & Completions"
    -zginit 'fpath=('"${(@q)ZGEN_COMPLETIONS}"' ${fpath})'
    if [[ ${ZGEN_AUTOLOAD_COMPINIT} == 1 ]]; then
        -zginit ""
        -zginit 'autoload -Uz compinit && \'
        -zginit '   compinit -C '"${ZGEN_COMPINIT_DIR_FLAG}"
    fi

    if [[ ${ZGENOM_ADD_PATH} == 1 ]] && [[ -d $(-zgen-bin-dir) ]]; then
        -zginit ""
        -zginit "# ### Bins"
        -zginit 'path=('$(-zgen-bin-dir)' ${path})'
    fi

    # Check for file changes
    if [[ ! -z "${ZGEN_RESET_ON_CHANGE}" ]]; then
        -zginit ""
        -zginit "# ### Recompilation triggers"

        local ages="$(command stat -Lc "%Y" 2>/dev/null $ZGEN_RESET_ON_CHANGE || \
                      command stat -Lf "%m" 2>/dev/null $ZGEN_RESET_ON_CHANGE)"
        local shas="$(cksum ${ZGEN_RESET_ON_CHANGE})"

        -zginit "read -rd '' ages <<AGES; read -rd '' shas <<SHAS"
        -zginit "$ages"
        -zginit "AGES"
        -zginit "$shas"
        -zginit "SHAS"

        -zginit 'if [[ -n "$ZGEN_RESET_ON_CHANGE" \'
        -zginit '   && "$(command stat -Lc "%Y" 2>/dev/null $ZGEN_RESET_ON_CHANGE || \'
        -zginit '         command stat -Lf "%m"             $ZGEN_RESET_ON_CHANGE)" != "$ages" \'
        -zginit '   && "$(cksum                     $ZGEN_RESET_ON_CHANGE)" != "$shas" ]]; then'
        -zginit '   printf %s\\n '\''-- zgenom: Files in $ZGEN_RESET_ON_CHANGE changed; resetting `init.zsh`...'\'
        -zginit '   zgenom reset'
        -zginit 'fi'
    fi

    # load prezto modules
    if [[ ${ZGEN_USE_PREZTO} == 1 ]]; then
        -zginit ""
        -zginit "# ### Prezto modules"
        printf %s "pmodload" >> "${ZGEN_INIT}"
        for module in "${ZGEN_PREZTO_LOAD[@]}"; do
            printf %s " ${module}" >> "${ZGEN_INIT}"
        done
    fi

    -zginit ""
    -zginit "# }}}"

    zgen-apply

    -zgpute "Compiling files ..."
    zgen-compile $ZGEN_DIR
    if [[ $ZGEN_DIR != $ZGEN_SOURCE ]]; then
        zgen-compile $ZGEN_SOURCE
    fi
    if [[ -n $ZGEN_CUSTOM_COMPDUMP ]]; then
        -zgen-compile $ZGEN_CUSTOM_COMPDUMP
    else
        set -o nullglob
        for compdump in $HOME/.zcompdump*; do
            if [ $compdump = *.zwc ]; then
                continue
            fi
            -zgen-compile $compdump
        done
    fi
}

zgen-apply() {
    fpath=(${(q)ZGEN_COMPLETIONS[@]} ${fpath})

    if [[ ${ZGEN_AUTOLOAD_COMPINIT} == 1 ]]; then
        -zgpute "Initializing completions ..."

        autoload -Uz compinit && \
            eval "compinit $ZGEN_COMPINIT_FLAGS"
    fi

    if [[ ${ZGENOM_ADD_PATH} == 1 ]] && [[ -d $(-zgen-bin-dir) ]]; then
        path=($(-zgen-bin-dir) $path)
    fi
}

-zgen-path-contains() {
    setopt localoptions nonomatch nocshnullglob nonullglob;
    [ -e "$1"/*"$2"(.,@[1]) ]
}

-zgen-get-zsh(){
    -zgputs "$(-zgen-get-clone-dir "$ZGEN_OH_MY_ZSH_REPO" "$ZGEN_OH_MY_ZSH_BRANCH")"
}

-zgen-compile() {
    local file=$1
    if [ ! $file.zwc -nt $file ]; then
        zcompile $file
    fi
}

zgen-compile() {
    local inp=$1
    if [ -z $inp ]; then
        -zgpute '`compile` requires one parameter:'
        -zgpute '`zgenom compile <location>`'
    elif [ -f $inp ]; then
        -zgen-compile $inp
    else
        set -o nullglob
        for file in $inp/**/*
        do
            # only files and ignore compiled files
            if [ ! -f $file ] || [[ $file = *.zwc ]]; then
                continue

            # Check for shebang if not:
            # - zsh startup file
            # - *.zsh
            # - *.sh
            # - zcompdump*
            elif [[ $file != *.zsh ]] \
                && [[ $file != *.sh ]] \
                && [[ $file != *zcompdump* ]] \
                && [[ ! $file =~ '\.z(shenv|profile|shrc|login|logout)$' ]]; then
                read -r firstline < $file
                if [[ ! $firstline =~ '^#!.*zsh' ]] 2>/dev/null; then
                    continue
                fi
            fi

            -zgen-compile $file
        done
    fi
}

zgen-load() {
    if [[ "$#" == 0 ]]; then
        -zgpute '`load` requires at least one parameter:'
        -zgpute '`zgenom load <repo> [location] [branch]`'
    elif [[ "$#" == 1 && ("${1[1]}" == '/' || "${1[1]}" == '.' ) ]]; then
        local location="${1}"
    else
        local repo="${1}"
        local file="${2}"
        local branch="${3}"
        local dir="$(-zgen-get-clone-dir ${repo} ${branch})"
        local location="${dir}/${file}"
        location=${location%/}

        # clone repo if not present
        if [[ ! -d "${dir}" ]]; then
            zgen-clone "${repo}" "${branch}"
        fi
    fi

    # source the file
    if [[ -f "${location}" ]]; then
        -zgen-source "${location}"

    # Prezto modules have init.zsh files
    elif [[ -f "${location}/init.zsh" ]]; then
        -zgen-source "${location}/init.zsh"

    elif [[ -f "${location}.zsh-theme" ]]; then
        -zgen-source "${location}.zsh-theme"

    elif [[ -f "${location}.theme.zsh" ]]; then
        -zgen-source "${location}.theme.zsh"

    elif [[ -f "${location}.zshplugin" ]]; then
        -zgen-source "${location}.zshplugin"

    elif [[ -f "${location}.zsh.plugin" ]]; then
        -zgen-source "${location}.zsh.plugin"

    # Classic ohmyzsh plugins have foo.plugin.zsh
    elif -zgen-path-contains "${location}" ".plugin.zsh" ; then
        for script (${location}/*\.plugin\.zsh(N)) -zgen-source "${script}"

    elif -zgen-path-contains "${location}" ".zsh" ; then
        for script (${location}/*\.zsh(N)) -zgen-source "${script}"

    elif -zgen-path-contains "${location}" ".sh" ; then
        for script (${location}/*\.sh(N)) -zgen-source "${script}"

    # Completions
    elif [[ -d "${location}" ]]; then
        -zgen-add-to-fpath "${location}"

    else
      if [[ -d ${dir:-$location} ]]; then
        -zgpute "Failed to load ${dir:-$location} -- ${file}"
      else
        -zgpute "Failed to load ${dir:-$location}"
      fi
    fi
}

zgen-loadall() {
    # shameless copy from antigen

    # Bulk add many bundles at one go. Empty lines and lines starting with a `#`
    # are ignored. Everything else is given to `zgen-load` as is, no
    # quoting rules applied.

    local line

    grep '^[[:space:]]*[^[:space:]#]' | while read line; do
        # Using `eval` so that we can use the shell-style quoting in each line
        # piped to `antigen-bundles`.
        eval "zgen-load $line"
    done
}

-zgen-bin-dir() {
    echo "$ZGEN_SOURCE/bin"
}
-zgen-bin() {
    local file="${1}"
    local name="${2}"
    if [[ -z $name ]]; then
        name=${file##*/}
    fi
    destination="$(-zgen-bin-dir)/$name"
    if [[ ! -e $destination ]]; then
        ln -s $file $destination
    fi
}

zgen-bin() {
    if [[ "$#" == 0 ]]; then
        -zgpute '`bin` requires at least one parameter:'
        -zgpute '`zgenom bin <repo> [location] [branch] [name]`'
        return
    fi
    local repo="${1}"
    local location="${2%/}"
    local branch="${3}"
    local name="${4}"
    local dir="$(-zgen-get-clone-dir ${repo} ${branch})"

    # clone repo if not present
    if [[ ! -d "${dir}" ]]; then
        zgen-clone "${repo}" "${branch}"
    fi

    if [[ ! -d $(-zgen-bin-dir) ]]; then
        mkdir -p $(-zgen-bin-dir)
    fi

    if [[ -n $location ]]; then
        location="${dir}/${location}"
        if [[ -f "${location}" ]]; then
            -zgen-bin "${location}" $name
            return
        fi
    elif [[ -d "${dir}/bin" ]]; then
        location="${dir}/bin"
    else
        location="${dir}"
    fi
    set -o nullglob
    for file in ${location}/*; do
        if [[ -x $file ]]; then
            -zgen-bin "$file"
        fi
    done
}

zgen-list() {
    if [[ $1 = 'bin' ]]; then
        ls $(-zgen-bin-dir)
    elif [[ -f "${ZGEN_INIT}" ]]; then
        cat "${ZGEN_INIT}"
    else
        -zgpute '`init.zsh` missing, please use `zgenom save` and then restart your shell.'
        return 1
    fi
}

zgen-selfupdate() {
    if [[ -e "${ZGEN_SOURCE}/.git" ]]; then
        (cd "${ZGEN_SOURCE}" \
            && git pull) \
            && zgen-reset
    else
        -zgpute "Not running from a git repository; cannot automatically update."
        return 1
    fi
}

# Backwards compatibilty for zgen
zgen-oh-my-zsh() { zgen-ohmyzsh $@ }

zgen-ohmyzsh() {
    local repo="$ZGEN_OH_MY_ZSH_REPO"
    local file="${1:-oh-my-zsh.sh}"

    zgen-load "${repo}" "${file}" "$ZGEN_OH_MY_ZSH_BRANCH"
}

zgen-prezto() {
    local repo="$ZGEN_PREZTO_REPO"
    local file="${1:-init.zsh}"

    # load prezto itself
    if [[ $# == 0 ]]; then
        ZGEN_USE_PREZTO=1
        zgen-load "${repo}" "${file}" "${ZGEN_PREZTO_BRANCH}"
        if [[ ${ZGEN_PREZTO_LOAD_DEFAULT} != 0 ]]; then
            -zgen-prezto-load "'environment' 'terminal' 'editor' 'history' 'directory' 'spectrum' 'utility' 'completion' 'prompt'"
        fi

    # this is a prezto module
    elif [[ $# == 1 ]]; then
        local module=${file}
        if [[ -z ${file} ]]; then
            -zgpute 'Please specify which module to load using `zgenom prezto <name of module>`'
            return 1
        fi
        -zgen-prezto-load "'$module'"

    # this is a prezto option
    else
        shift
        -zgen-prezto-option ${file} ${(qq)@}
    fi

}

zgen-pmodule() {
    local repo="${1}"
    local branch="${2}"

    local dir="$(-zgen-get-clone-dir ${repo} ${branch})"

    # clone repo if not present
    if [[ ! -d "${dir}" ]]; then
        zgen-clone "${repo}" "${branch}"
    fi

    local module="${repo:t}"
    -zgen-prezto-load "'${module}'"
}

zgenom() {
    local cmd="${1}"
    if [[ -z "${cmd}" ]]; then
        -zgputs 'usage: `zgenom [command | instruction] [options]`'
        -zgputs "    commands: list, saved, reset, clone, update, selfupdate, compile"
        -zgputs "    instructions: load, bin, ohmyzsh, pmodule, prezto, save, apply"
        return 1
    fi

    shift

    if functions "zgen-${cmd}" > /dev/null ; then
        "zgen-${cmd}" "${@}"
    else
        -zgpute 'Command not found: `'"${cmd}"\`
        return 1
    fi
}

ZSH=$(-zgen-get-zsh)

# Run initialization only once
if [[ -z $ZGENOM_LAZY_LOCK ]]; then
    fpath=($ZGEN_SOURCE $fpath)
    zgen-init
fi
