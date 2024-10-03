# zgenom

A lightweight yet powerful plugin manager for Zsh.

It is a superset of the brilliant [zgen](https://github.com/tarjoilija/zgen).
Providing more features and bugfixes while being fully backwards compatible.
Have a look at the [migration guide](#migration-from-zgen) if you're
currently using `zgen`. Also have a look at [new features](#new-features) of
zgenom.

Zgenom provides you simple commands for managing plugins. It installs your
plugins and generates a static init script that will source them for you every
time you run the shell. We do this to save some startup time by not having to
execute time consuming logic (plugin checking, updates, etc) every time a new
shell session is started. This means that you have to manually check for
updates (`zgenom update`) and reset the init script (`zgenom reset`) whenever
you add or remove plugins.

Zgenom does have a `zgenom autoupdate` which checks for updates periodically
without startup penalty or having to wait for the plugins to update. See
[here](#run-updates-automatically) for more information.

## Installation

<details><summary>...</summary>

Clone the zgenom repository:

```zsh
git clone https://github.com/jandamm/zgenom.git "${HOME}/.zgenom"
```

Edit your .zshrc file to load zgenom:

```zsh
# load zgenom
source "${HOME}/.zgenom/zgenom.zsh"
```

Place the following code after the one above to load ohmyzsh for example, see
[Example](#example-zshrc) and [Usage](#usage) for more details.

```zsh
# if the init script doesn't exist
if ! zgenom saved; then

  # specify plugins here
  zgenom ohmyzsh

  # generate the init script from plugins above
  zgenom save
fi
```
If you're currently using zgen [see below](#migration-from-zgen).

</details>

## Example .zshrc

```zsh
# load zgenom
source "${HOME}/.zgenom/zgenom.zsh"

# Check for plugin and zgenom updates every 7 days
# This does not increase the startup time.
zgenom autoupdate

# if the init script doesn't exist
if ! zgenom saved; then
    echo "Creating a zgenom save"

    # Add this if you experience issues with missing completions or errors mentioning compdef.
    # zgenom compdef

    # Ohmyzsh base library
    zgenom ohmyzsh

    # You can also cherry pick just parts of the base library.
    # Not loading the base set of ohmyzsh libraries might lead to issues.
    # While you can do it, I won't recommend it unless you know how to fix
    # those issues yourself.

    # Remove `zgenom ohmyzsh` and load parts of ohmyzsh like this:
    # `zgenom ohmyzsh path/to/file.zsh`
    # zgenom ohmyzsh lib/git.zsh # load git library of ohmyzsh

    # plugins
    zgenom ohmyzsh plugins/git
    zgenom ohmyzsh plugins/sudo
    # just load the completions
    zgenom ohmyzsh --completion plugins/docker-compose

    # Install ohmyzsh osx plugin if on macOS
    [[ "$(uname -s)" = Darwin ]] && zgenom ohmyzsh plugins/macos

    # prezto options
    zgenom prezto editor key-bindings 'emacs'
    zgenom prezto prompt theme 'sorin'

    # prezto and modules
    # If you use prezto and ohmyzsh - load ohmyzsh first.
    zgenom prezto
    zgenom prezto command-not-found

    # Load prezto tmux when tmux is installed
    if hash tmux &>/dev/null; then
        zgenom prezto tmux
    fi

    zgenom load zsh-users/zsh-syntax-highlighting
    zgenom load /path/to/super-secret-private-plugin

    # use a plugin file
    # The file must only contain valid parameters for `zgenom load`
    zgenom loadall < path/to/plugin/file

    # bulk load
    zgenom loadall <<EOPLUGINS
        zsh-users/zsh-history-substring-search
        /path/to/local/plugin
EOPLUGINS
    # ^ can't indent this EOPLUGINS

    # add binaries
    zgenom bin tj/git-extras

    # completions
    zgenom load zsh-users/zsh-completions

    # theme
    zgenom ohmyzsh themes/arrow

    # save all to init script
    zgenom save

    # Compile your zsh files
    zgenom compile "$HOME/.zshrc"
    # Uncomment if you set ZDOTDIR manually
    # zgenom compile $ZDOTDIR

    # You can perform other "time consuming" maintenance tasks here as well.
    # If you use `zgenom autoupdate` you're making sure it gets
    # executed every 7 days.

    # rbenv rehash
fi
```

You can also use `zgenom` in a more dynamic way:

```zsh
if ! zgenom saved; then
    # ...
fi

# Load plugins on a per shell basis:
# (Only load chucknorris on weekends)
if is_weekend; then
    zgenom ohmyzsh plugins/chucknorris
    # Be aware that this will be loaded dynamically and increases the startup time.
    # When using `zgenom clean` this plugin might be removed as well (unless it is
    # currently loaded).
fi

# Load plugins lazily when used:
# (When brew is first executed, load ohmyzsh brew and then use brew)
alias brew='unalias brew && zgenom ohmyzsh brew && brew'
# Be aware that this might not work for all plugins.
```

**Note:** The more dynamic examples are not official features. They are rather
byproducts. They are included as ideas you can test out. In most cases it's
probably a better idea to always load the plugin instead.

### Migration from zgen

The quickest way would be to just use a new remote. This way no plugins have to
be cloned again.

```zsh
cd $ZGEN_SOURCE
git remote add zgenom https://github.com/jandamm/zgenom.git
git fetch zgenom
git switch main
zgen reset
```

When you start a new shell your plugins will be migrated. You don't have to
change your `.zshrc`.

**Note:** `zgen` is only present if you source `zgen.zsh`.

The preferred way would be to just delete zgen and start fresh.

**Note:** If you keep `~/.zgen` around, zgenom will use it to store the plugins
in there. So please `rm` or `mv` the folder before starting a new shell.
(Otherwise the plugins will be migrated - with a prompt)

If you've specified branches (e.g. `main`) you can probably remove those since
zgenom should take care of picking the right branch for you. Unless you're
using a "pre-release" branch.

**Note:** While this README uses `zgenom` and `ohmyzsh` the old versions `zgen`
and `oh-my-zsh` can be used interchangeably.


## New features

- Compiling your sourced scripts.
- Add `zgenom compile` in case you want to recursively compile your dotfiles (manually).
- Add `zgenom bin` to add an executable to your `$PATH`.
- Lazy loading zgenom - only the bare minimum you need for the current shell is loaded.
- The default `$ZGEN_DIR` is `path/to/zgenom/sources` (except when you have `~/.zgen` for backwards compatibility).
  So most usecases shouldn't need to modify `$ZGEN_DIR` anymore.
- Allow cloning without submodules `zgenom clone <repo> --no-submodules`.
- Full support for non `master` branches (e.g. `main`). This includes following
  a new default branch.
- compinit with custom flags wasn't working properly.
- Update to `ohmyzsh/ohmyzsh`.
- Implement the [Zsh Plugin Standard](#zsh-plugin-standard).
- Add `zgenom clean` to remove all unused plugins.
- Add `zgenom autoupdate` to check for updates periodically and dispatch it to
  the background to remove any waiting times.
- Allow just adding a plugins directory to fpath using `--completion` with
  `load` or `ohmyzsh`.
- Add `zgenom compdef` to add `compdef` before loading plugins.

## Usage

<details><summary>...</summary>

### ohmyzsh

This is a handy shortcut for installing ohmyzsh plugins. They can be loaded
using `zgenom load` too with a significantly longer format.

#### Load ohmyzsh base

It's a good idea to load the base components before specifying any plugins.

```zsh
zgenom ohmyzsh
```

#### Load ohmyzsh plugins

```zsh
zgenom ohmyzsh <location>
```

#### Example

```zsh
zgenom ohmyzsh
zgenom ohmyzsh plugins/git
zgenom ohmyzsh plugins/sudo
zgenom ohmyzsh plugins/command-not-found
# Just use the completions in this directory
zgenom ohmyzsh --completion plugins/docker-compose

zgenom ohmyzsh themes/arrow
```

### Prezto

#### Load Prezto

```zsh
zgenom prezto
```

This will create a symlink in the `$ZSHDOTDIR` or `$HOME` directory. This is
needed by prezto.

**Note:** When `zgenom prezto` is used with `zgenom ohmyzsh` together, `prezto`
should be **put behind** `ohmyzsh`. Or prompt theme from prezto may not display
as expected.

#### Load prezto plugins

```zsh
zgenom prezto <modulename>
```

This uses the Prezto method for loading modules.

**Note:** Some modules from prezto are enabled by default. Use
`ZGEN_PREZTO_LOAD_DEFAULT=0` to disable this behavior.

#### Load a repo as Prezto plugins

```zsh
zgenom pmodule <reponame> <branch>
```

This uses the Prezto method for loading the module. It creates a symlink and
calls `pmodule`.

#### Set prezto options

```zsh
zgenom prezto <modulename> <option> <value(s)>
```

This must be used before the module is loaded. Or if the default modules should
be loaded (default) these settings must be done before the `zgenom prezto`
command. `module` is prepended if the name does not start with `module`,
`prezto` or a `*`, `prezto` is prepended if it does not start with `prezto`.

### Using a default branch

If you don't specify a branch the remotes default branch will be used. (The one
you see when you open the github page for a project). When the default branch
is used zgenom will try to follow this branch. When you add a plugin with the
default branch `master` and the maintainer decides to use `main` instead zgenom
will switch from `master` to `main` for you.

If you have to specify a branch but still want this behavior you can use `___`
instead of a branch name.

When you are currently using zgenom and have plugins without a branch specified
you'll be asked (on `zgenom load`) if you want to migrate the old plugin or clone
it freshly.

**Be aware that this feature will delete the local branch when the head
changes.** So don't use it if you plan to tamper with clone locally. If you
just want to use plugins this won't affect you.

[See this comment for more
information.](https://github.com/jandamm/zgenom/issues/48#issuecomment-763740949)

### General zgenom functions

#### Load plugins and completions

```zsh
zgenom load <repo> [location] [branch] [--completion] [--pin=full_commit_hash]
```

Zgenom tries to source any scripts from `location` using a "very smart matching
logic". It will also append `location` to `$fpath`.
If you add `--completion` it will only append `location` to `fpath`.

You can use `--pin` with a full commit hash instead of a branch to prevent the repo from updating.

- `repo`
  - github `user/repository` or path to a repository
  - currently supported formats for a repository path:
    - any local repository
    - `git://*`
    - `https://*`
    - `http://*`
    - `ssh://*`
      - Note that repos cloned using SSH can exhibit odd behavior during [autoupdates](#run-updates-automatically) if the associated ssh-key has a passphrase and is not present in an agent.  Observing several `zsh` processes using 100% CPU is a symptom of this.
    - `git@*:*/*`
- `location`
  - relative path to a script/folder
  - useful for repositories that don't have proper plugin
- `branch`
  - specifies the git branch to use
- `--completion`
  - Don't source any file. Just add the given location to `$fpath`

#### Load executables

```zsh
zgenom bin <repo> --location --branch --name --glob
```

If `location` is omitted `./bin` is checked if `./bin` doesn't exist `.` is
checked. All executables in the found folder will be added to the path.

If `location` is a folder all executables of this folder are added to the path.

It's also possible to provide a glob where every matching executable is added
to the path.

**Note:** This may lead to unwanted side-effects so it's recommended that you
specify the files you need. You can use `zgenom list --bin` to check which
executables are added.

```zsh
# Add 'fasd' to the path and rename it to 'fast'.
zgenom bin 'clvv/fasd' --location fasd --name fast

# Add all executables which are in bin, start with git- and end with -branch.
zgenom bin 'tj/git-extras' --glob 'bin/git-*-branch'
```

#### Bulk load plugins

```zsh
zgenom loadall <plugins>
```

You can use it to load plugins listed in a file or provided by heredoc.
Please see example `.zshrc` for usage.

#### Generate init script

```zsh
zgenom save
```

It is recommended to save the plugin sourcing part to a static init script so
we don't have to go through the time consuming installing/updating part every
time we start the shell (or source .zshrc)

If you don't want use a init script call `zgenom apply` after you've loaded all
plugins. It'll take care of compinit and adding the loaded bins to your PATH.
The default path of the `.zcompdump` is `$ZGEN_DIR/zcompdump_$ZSH_VERSION`. You
can change it by setting `$ZGEN_CUSTOM_COMPDUMP`.

#### Remove init script

```zsh
zgenom reset
```

Removes the init script so it will be created next time you start the shell.
You must run this every time you add or remove plugins to trigger the changes.

This will not remove the plugins physically from disk.

#### Check for an init script

```zsh
zgenom saved
```

Returns 0 if an init script exists.

It also sources the init script if it exists.

**Note:** If you don't use `zgenom saved` you should call `zgenom init` manually.

#### Update all plugins and reset

```zsh
zgenom update
```

Pulls updates on every plugin repository and removes the init script.

#### Update zgenom

```zsh
zgenom selfupdate
```

#### Run updates automatically

Using `autoupdate` disables ohmyzsh automatic updates since zgenom will do
the same. You can use `--keep-ohmyzsh` to keep ohmyzsh automatic updates
enabled.

```zsh
source path/to/zgenom.zsh

# Update every 7 days
zgenom autoupdate

# Update every 3 days
zgenom autoupdate 3

# Update only zgenom every 14 days
zgenom autoupdate --self 14

# Update only plugins every 7 days
zgenom autoupdate --plugin 7

# Update plugins every 7 days and zgenom every 14 days
zgenom autoupdate --plugin 7 --self 14

# Update every 7 days and run updates in the current shell
zgenom autoupdate --no-background

if ! zgenom saved; then
    # load plugins
```

Call `zgenom selfupdate` and `zgenom update` regularly. If you call one of
those manually this will also reset the timer. So you can use it to make sure
you update every x days.

Make sure to call it before you check for the init file with `zgenom saved`.

These backups will run fully in the background so you won't any slowdown
in your startup time. When the update is complete and you start a new
shell everything is prepared so you don't have to wait then either. When
starting a new shell after a completed update you will get a log showing you
what happened in the background.

There is also an option to run the updates in sync by adding `--no-background`.
This will show you any output as it happens and you have to wait until you can
use the shell.
This also increases the startup time around 17% (~16ms) in order
to check if an update has to be done. This figure may vary depending on your
plugins and machine.

**Note:** If your .zshrc contains any interactive prompts you might encounter
issues with some terminals. In this case you might want to try running the
updates in sync using `--no-background`.

#### Fix issues with compdef

```zsh
zgenom compdef
```

`compdef` is only available after `compinit` is called which zgenom executes
after all plugins are loaded.
Some plugins might use `compdef` and either error or fail to add completions
(if they check the existence of `compdef`).
Running `zgenom compdef` will provide a `compdef` and apply all calls after
compinit was done.

#### Clean zgenom plugins

```zsh
zgenom clean
```

Removes every plugin which isn't loaded in the current shell session.

#### Watch files for modifications

You can automate the process of running `zgenom reset` by specifying a list of
files to `ZGEN_RESET_ON_CHANGE`. These files will be checked and if a change is
detected `zgenom reset` is called.

```zsh
ZGEN_RESET_ON_CHANGE=(${HOME}/.zshrc ${HOME}/.zshrc.local)
```

#### Compile your .zshrc files

```zsh
zgenom compile .zshrc
zgenom compile ~/.zsh
zgenom compile $ZDOTDIR # If you set ZDOTDIR manually
```

The first will just compile your `.zshrc`. The second one will compile every
zsh file it can recursively find in `~/.zsh`. You might not want to add any of
these lines to your `.zsrhc` but run them manually or automatically in the
background.

You can provide the options `-UzkMR` to `zgenom compile`. They are just passed
to `zcompile`. See `man zshbuiltins` for an explanation of the flags.

#### Safely access internal api

Calling any function matching `__zgenom-*` is assumed unsafe and the function
is considered private. So it may be renamed anytime without further notice.

To provide a way to safely access some internal api `zgenom api` is introduced.
Please use the zsh completion to check what parts of the internal api is
exposed.

</details>

## Notes

While this README uses `zgenom` and `ohmyzsh` the old versions `zgen` and
`oh-my-zsh` can be used interchangeably.

Environment variables are still prefixed with `ZGEN_` to keep backwards
compatibility. When `zgenom` introduces new variables they are prefixed with
`ZGENOM_`.

Be aware that `zgenom` tries to handle [`compinit`][compinit] for you to allow
for the fastest possible initialization times. However, this functionality will
be disabled if you've already called `compinit` yourself before sourcing
`zgenom.zsh`. Alternatively, you can disable it yourself by disabling
`$ZGEN_AUTOLOAD_COMPINIT`.

  [compinit]: <http://zsh.sourceforge.net/Doc/Release/Completion-System.html#Use-of-compinit> "Zsh manual 20.2.1: Use of compinit"

## Extensions

Extensions may be a bit of a stretch. Every function matching `zgenom-*` is
callable like `zgenom *`. Every completion function matching `_zgenom_*` is
called by `_zgenom`.

Also `$ZGENOM_EXTENSIONS` can be used to add an entry to `zgenom help` and
subcommand completion.

To provide an extension called `abc` you define `zgenom-abc` in your plugin.
Then you can add a description: `ZGENOM_EXTENSIONS+=('abc:Some description')`.
To provide additional completions you can define `_zgenom_abc` which will be
called when the prompt starts with `zgenom abc`.

Existing extensions:

- [eval](https://github.com/jandamm/zgenom-ext-eval): Use `zgenom` to quickly
  generate plugins from a command or heredoc.
- [release](https://github.com/jandamm/zgenom-ext-release): Use `zgenom` and
  `gh` to download github releases.
- [run](https://github.com/jandamm/zgenom-ext-run): Use `zgenom` to run
  commands in the plugin folder (e.g. `make`).

Please create a PR to add your extension here :)

**Note:** It is not recommended to use the private api (`__zgenom-*`) since it
may change without further notice. Use `zgenom api` instead.

## Other resources

The [awesome-zsh-plugins](https://github.com/unixorn/awesome-zsh-plugins) list
contains many zgenom compatible zsh plugins & themes that you may find useful.

There's a [zsh-quickstart-kit](https://github.com/unixorn/zsh-quickstart-kit)
for using zsh and zgenom that does a guided setup of zgenom, including
installing a starting sampler of useful plugins.

### [Zsh Plugin Standard](https://zdharma-continuum.github.io/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html)

The Zsh Plugin Standard describes how a plugin for zsh should be written and
what the plugin manager should do to support a plugin.

Zgenom does support most paragraphs of this standard. (1-3 & 7-9 as of this writing).
The unsupported paragraphs are all related to unloading (which isn't currently
supported) and a hook for plugins that the plugin manager should call on
updates (you probably shouldn't use zgenom if your plugin requires this).

**Note:** *Paragraph 3* says to add every `./bin` folder found in a plugin.
I personally wouldn't want this so this is off by default. Please set
`ZGENOM_AUTO_ADD_BIN=1` before sourcing `zgenom.zsh` to enable this paragraph.

## Releases

Every commit which is merged into `main` is considered a stable release.
Every open PR is considered a beta release that I test locally. You're welcome to test it on your machine as well.

## Alternatives

There are a lot of alternatives. The most popular is probably [antigen](https://github.com/zsh-users/antigen) but it's only in maintenance mode.
An extensive list can be found [here](https://github.com/mattmc3/zsh_unplugged#newspaper_roll-current-state).

You should think what features you need from a plugin manager.
At its purest form it's just `git clone` and `source path/to/plugin/file.zsh`. So nothing you couldn't do yourself.

But there are some subtleties that you might not think of. For example the default branch could change (e.g. `master` to `main`) and keep you from updating the plugin without an error message.

With `zgenom` I don't even think about zsh plugins.
Every seven days `zgenom` and the plugins get updated automatically. `zgenom` can also detect new plugins and install them automatically as well.

## Feedback

If you like this plugin, star it! It's a great way of getting feedback. The same
goes for reporting issues or feature requests.
