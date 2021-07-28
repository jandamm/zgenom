# save
-zginit() { __zgenom_out "$*" >> "${ZGEN_INIT}" ;}

# -get-clone-dir
-zgen-encode-url () {
    # Remove characters from a url that don't work well in a filename.
    # Inspired by -anti-get-clone-dir() method from antigen.
    local url="${1}"
    url="${url//\//-SLASH-}"
    url="${url//\:/-COLON-}"
    url="${url//\|/-PIPE-}"
    url="${url//~/-TILDE-}"
    __zgenom_out "$url"
}

# bin
# pmodule
# clone
# load
-zgen-get-clone-dir-legacy() { -zgen-get-clone-dir "$1" "${2:-___}" "-" }
-zgen-get-clone-dir() {
    local repo="${1}"
    local branch="${2:-___}"
    local separator="${3:-/}"

    if [[ -e "${repo}/.git" ]]; then
        __zgenom_out "${ZGEN_DIR}/local/${repo:t}${separator}${branch}"
    else
        # Repo directory will be location/reponame
        local reponame="${repo:t}"
        # Need to encode incase it is a full url with characters that don't
        # work well in a filename.
        local location="$(-zgen-encode-url ${repo:h})"
        repo="${location}/${reponame}"
        __zgenom_out "${ZGEN_DIR}/${repo}${separator}${branch}"
    fi
}

# clone
-zgen-get-clone-url() {
    local repo="${1}"

    if [[ -e "${repo}/.git" ]]; then
        __zgenom_out "${repo}"
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
        __zgenom_out "${repo}"
    fi
}

# clone
-zgen-migrate-dir() {
    local dir="${1}"
    local repo="${2}"
    local branch="${3}"
    command mkdir -p ${dir%/*} && command mv $(-zgen-get-clone-dir-legacy ${repo} ${branch}) $dir
}

# load
-zgen-add-to-fpath() {
    local completion_path="${1}"

    # Add the directory to ZGEN_COMPLETIONS array if not present
    if [[ ! "${ZGEN_COMPLETIONS[@]}" =~ ${completion_path} ]]; then
        ZGEN_COMPLETIONS+=("${completion_path}")
        fpath=("${completion_path}" $fpath)
    fi
}

# load
-zgen-source() {
    local source_file="${1}"
    local repo_id

    if [[ ! "${ZGEN_LOADED[@]}" =~ "${source_file}" ]]; then
        if [[ -z "${repo}" ]]; then
            repo_id="/${${source_file:h}:t}"
        elif [[ "${dir}" = *ohmyzsh* ]] || [[ "${dir}" = *oh-my-zsh* ]]; then
            repo_id="${repo}/${file}"
        else
            repo_id="${repo}"
        fi

        ZGEN_LOADED+=("${source_file}")
        ZGENOM_LOADED+=("${repo_id}")

        if [[ -d "$dir/functions" ]]; then
            -zgen-add-to-fpath "$dir/functions"
        else
            -zgen-add-to-fpath "${source_file:h}"
        fi

        zsh_loaded_plugins+=( "$repo_id" )
        ZERO="${source_file}" source "${source_file}"
    fi
}

# prezto
-zgen-prezto-option() {
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

# prezto
# pmodule
-zgen-prezto-load() {
    local params="$*"
    local cmd="pmodload ${params[@]}"

    # execute in place
    eval $cmd

    if [[ ! "${ZGEN_PREZTO[@]}" =~ "${cmd}" ]]; then
        ZGEN_PREZTO_LOAD+=("${params[@]}")
    fi
}

# update
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

# update
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
                __zgenom_out
                __zgenom_out "New default branch: '$branch'."
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

# update
-zgen-git-pull-fatal() {
    __zgenom_err
    __zgenom_err "Could not find default branch."
    __zgenom_err "Please delete the repos folder and let zgenom clone it again."
    __zgenom_err
}

# load
-zgen-path-contains() {
    setopt localoptions nonomatch nocshnullglob nonullglob;
    [ -e "$1"/[^_]*"$2"(.,@[1]) ]
}

# save
# compile
-zgen-compile() {
    local file=$1
    if [ ! $file.zwc -nt $file ] && [[ -r $file ]]; then
        zcompile -U $file
    fi
}

# bin
-zgen-bin() {
    local file="${1}"
    local name="${2}"
    if [[ -z $name ]]; then
        name=${file##*/}
    fi
    destination="$ZGENOM_SOURCE_BIN/$name"
    if [[ ! -e $destination ]]; then
        ln -s $file $destination
    fi
}
