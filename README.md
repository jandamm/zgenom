# zgenom

A lightweight yet powerful plugin manager for Zsh.

It is a superset of the brilliant [zgen](https://github.com/tarjoilija/zgen).
Providing more features and bugfixes while being fully backwards compatible.
Have a look at the [migration guide](#Migration-from-zgen) if you're
currently using `zgen`. Also have a look at [new features](#New-features) of
zgenom.

Zgenom provides you simple commands for managing plugins. It installs your
plugins and generates a static init script that will source them for you every
time you run the shell. We do this to save some startup time by not having to
execute time consuming logic (plugin checking, updates, etc). This means that
you have to manually check for updates (`zgenom update`) and reset the init
script (`zgenom reset`) whenever you add or remove plugins.

## Installation

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
[Usage](#Usage) for more details.

```zsh
# if the init script doesn't exist
if ! zgenom saved; then

  # specify plugins here
  zgenom ohmyzsh

  # generate the init script from plugins above
  zgenom save
fi
```

### Migration from zgen

To get started you just have to clone this repository instead of zgen or you
change remotes.

This will take care that all files including the compdump are compiled after
you run `zgenom reset` once. Besides this automatic compiling you can use zgenom
to compile your dotfiles as well. (see below)

To enable lazy loading change `source "${HOME}/.zgen/zgen.zsh"` to `source
"${HOME}/.zgen/zgenom.zsh"`.

**Note:** While this README uses `zgenom` and `ohmyzsh` the old versions `zgen`
and `oh-my-zsh` can be used interchangeably.

## Usage

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
zgenom ohmyzsh themes/arrow
```

### Prezto

#### Load Prezto

```zsh
zgenom prezto
```

This will create a symlink in the `$ZSHDOTDIR` or `$HOME` directory. This is
needed by prezto.

**Note**: When `zgenom prezto` is used with `zgenom ohmyzsh` together, `prezto`
should be **put behind** `ohmyzsh`. Or prompt theme from prezto may not display
as expected.

#### Load prezto plugins

```zsh
zgenom prezto <modulename>
```

This uses the Prezto method for loading modules.

**Note**: Some modules from prezto are enabled by default. Use
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

### General zgenom functions

#### Load plugins and completions

```zsh
zgenom load <repo> [location] [branch]
```

Zgenom tries to source any scripts from `location` using a "very smart matching
logic". It will also append `location` to `$fpath`.

- `repo`
  - github `user/repository` or path to a repository
  - currently supported formats for a repository path:
    - any local repository
    - `git://*`
    - `https://*`
    - `http://*`
    - `ssh://*`
    - `git@*:*/*`
- `location`
  - relative path to a script/folder
  - useful for repositories that don't have proper plugin support like `zsh-users/zsh-completions`
- `branch`
  - specifies the git branch to use

#### Load executables

```zsh
zgenom load <repo> [location] [branch] [name]
```

If `location` is omitted `./bin` is checked if `./bin` doesn't exist `.` is
checked. All executables in the found folder will be added to the path.

If `location` is a folder all executables of this folder are added to the path.

**Note:** This may lead to unwanted side-effects so it's recommended that you
specify the files you need. You can use `zgenom list bin` to check which
executables are added.

```zsh
# Add 'fasd' to the path and rename it to 'fast'.
# Also use and follow the default branch.
zgenom bin 'clvv/fasd' fasd ___ fast
```

#### Bulk load plugins

```zsh
zgenom loadall <plugins>
```

Please see example `.zshrc` for usage.

#### Generate init script

```zsh
zgenom save
```

It is recommended to save the plugin sourcing part to a static init script so
we don't have to go through the time consuming installing/updating part every
time we start the shell (or source .zshrc)

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

#### Update all plugins and reset

```zsh
zgenom update
```

Pulls updates on every plugin repository and removes the init script.

#### Update zgenom

```zsh
zgenom selfupdate
```

#### Clean zgenom plugins

```zsh
zgenom clean
```

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
zgenom compile $ZDOTDIR
```

The first will just compile your `.zshrc`. The second one will compile every
zsh file it can recursively find in `~/.zsh`. You might not want to add any of
these lines to your `.zsrhc` but run them manually or automatically in the
background.

## [Zsh Plugin Standard](https://zdharma.org/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html)

The Zsh Plugin Standard describes how a plugin for zsh should be written and
what the plugin manager should do to support a plugin.

Zgenom does support most paragraphs of this standard. (1-3 & 7-9 as of this writing).
The unsupported paragraphs are all related to unloading (which isn't currently
supported) and a hook for plugins that the plugin manager should call on
updates (you probably shouldn't use zgenom if your plugin requires this).

**Note:** *Paragraph 3* says to add every `./bin` folder found in a plugin.
I personally wouldn't want this so this is off by default. Please set
`ZGENOM_AUTO_ADD_BIN=1` before sourcing `zgenom.zsh` to enable this paragraph.

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

## New features

- Compiling your sourced scripts.
- Add `zgenom compile` in case you want to recursively compile your dotfiles (manually).
- Add `zgenom bin` to add an executable to your `$PATH`.
- Lazy loading zgenom by sourcing `zgenom.zsh` instead of `zgen.zsh`.
- The default `$ZGEN_DIR` is a sources subdirectory where you cloned `zgenom`
  to (except when you have `~/.zgen` for backwards compatibility).
- Allow cloning without submodules `zgenom clone [repo] --no-submodules`.
- Full support for non `master` branches (e.g. `main`). This includes following
  a new default branch.
- compinit with custom flags wasn't working properly.
- Update to `ohmyzsh/ohmyzsh`.
- Implement the [Zsh Plugin Standard](https://zdharma.org/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html).
- Add `zgenom clear` to remove all unused plugins.

## Example .zshrc

```zsh
# load zgenom
source "${HOME}/.zgenom/zgenom.zsh"

# if the init scipt doesn't exist
if ! zgenom saved; then
    echo "Creating a zgenom save"

    zgenom ohmyzsh

    # plugins
    zgenom ohmyzsh plugins/git
    zgenom ohmyzsh plugins/sudo
    zgenom ohmyzsh plugins/commandnotfound
    zgenom load zsh-users/zsh-syntax-highlighting
    zgenom load /path/to/super-secret-private-plugin

    # bulk load
    zgenom loadall <<EOPLUGINS
        zsh-users/zsh-history-substring-search
        /path/to/local/plugin
EOPLUGINS
    # ^ can't indent this EOPLUGINS

    # completions
    zgenom load zsh-users/zsh-completions src

    # theme
    zgenom ohmyzsh themes/arrow

    # save all to init script
    zgenom save
fi
```

### Example .zshrc for prezto

Here is a partial example how to work with prezto

```zsh
...
    echo "Creating a zgenom save"

    # prezto options
    zgenom prezto editor key-bindings 'emacs'
    zgenom prezto prompt theme 'sorin'

    # prezto and modules
    zgenom prezto
    zgenom prezto git
    zgenom prezto command-not-found
    zgenom prezto syntax-highlighting

    # plugins
    zgenom load /path/to/super-secret-private-plugin
....

```

## Other resources

The [awesome-zsh-plugins](https://github.com/unixorn/awesome-zsh-plugins) list
contains many zgenom compatible zsh plugins & themes that you may find useful.

There's a quickstart kit for using zsh and zgenom at
[zsh-quickstart-kit](https://github.com/unixorn/zsh-quickstart-kit) that guides
you through setting up zgenom and includes a sampler of useful plugins.

The [autoupdate-zgen](https://github.com/unixorn/autoupdate-zgen) plugin will
enable your zgen to periodically update itself and your list of plugins.
(Despite the name it should still work well with zgenom)

## Alternatives

- [antigen](https://github.com/zsh-users/antigen) - popular and mature
- [zplug](https://github.com/b4b4r07/zplug) - well performing and has a fancy UI
- [zinit](https://github.com/zdharma/zinit) - very much magic and a turbo mode
