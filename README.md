# zgenom

A lightweight plugin manager for Zsh based on
[zgen](https://github.com/tarjoilija/zgen). It is a superset of the brilliant
`zgen`. Providing more features and bugfixes while being fully backwards
compatible.

## Migration from zgen

To get started you just have to clone this repo instead of zgen or you change remotes.

This will take care that all files including the compdump are compiled after
you run `zgen reset` once. Besides this automatic compiling you can use zgenom
to compile your dotfiles as well. (see below)

To enable lazy loading change `source "${HOME}/.zgen/zgen.zsh"` to `source "${HOME}/.zgen/zgenom.zsh"`.

## Differences to zgen

New features:

- Compiling your sourced scripts.
- Add `zgen compile` in case you want to recursively compile your dotfiles (manually).
- Add `zgen bin` to add an executable to your `$PATH`.
- Lazy loading zgenom by sourcing `zgenom.zsh` instead of `zgen.zsh`.
- The default `$ZGEN_DIR` is a sources subdirectory where you cloned `zgenom` to (except when you have `~/.zgen` for backwards compatibility).
- Allow cloning without submodules `zgen clone [repo] --no-submodules`.
- Full support for non `master` branches (e.g. `main`). This includes following a new default branch.

Bugfixes/maintenance:

- compinit with custom flags wasn't working properly.
- Update to `ohmyzsh/ohmyzsh`.

### zgen compile

```zsh
zgen compile .zshrc
zgen compile ~/.zsh
zgen compile $ZDOTDIR
```

The first will just compile your `.zshrc`. The second one will compile every
zsh file it can recursively find in `~/.zsh`. You might not want to add any of
these lines to your `.zsrhc` but run them manually or automatically in the
background.

### zgen bin

```zsh
zgen bin 'clvv/fasd'
```

By default this will look in `./bin`. If this folder does not exist it will
look in `.`. If the executable isn't in these folders you can specify either a
folder or a file. If you don't specify anything at all or specify a folder all
executables in this path will be used. This may lead to unwanted side-effects
so it's recommended that you specify the files you need. You can use `zgen list
bin` to check for such cases.

```zsh
# Add 'fasd' to the path and rename it to 'fast'
zgen bin 'clvv/fasd' fasd master fast
```

### Using a default branch

If you don't specify a branch the remotes default branch will be used. (The one
you see when you open the github page for a project). When the default branch
is used zgenom will try to follow this branch. When you add a plugin with the
default branch `master` and the maintainer decides to use `main` instead zgenom
will switch from `master` to `main` for you.

If you have to specify a branch but still want this behavior you can use `___`
instead of a branch name.

When you are currently using zgen and have plugins without a branch specified
you'll be asked (on `zgen load`) if you want to migrate the old plugin or clone
it freshly.

**Be aware that this feature will delete the local branch when the head changes.**
So don't use it if you plan to tamper with clone locally. If you just want to use
plugins this won't affect you.

## zgen

A lightweight plugin manager for Zsh inspired by [Antigen](https://github.com/zsh-users/antigen). Keep your `.zshrc` clean and simple.

Zgen provides you a few simple commands for managing plugins. It installs your plugins and generates a static init script that will source them for you every time you run the shell. We do this to save some startup time by not having to execute time consuming logic (plugin checking, updates, etc). This means that you have to manually check for updates (`zgen update`) and reset the init script (`zgen reset`) whenever you add or remove plugins.

The motive for creating zgen was to have plugins quickly installed on a new machine without getting the startup lag that Antigen used to give me.

## Installation

Clone the zgen repository

    git clone https://github.com/tarjoilija/zgen.git "${HOME}/.zgen"

Edit your .zshrc file to load zgen

    # load zgen
    source "${HOME}/.zgen/zgen.zsh"

Place the following code after the one above to load oh-my-zsh for example, see Usage for more details

    # if the init script doesn't exist
    if ! zgen saved; then

      # specify plugins here
      zgen oh-my-zsh

      # generate the init script from plugins above
      zgen save
    fi

## Usage

### oh-my-zsh

This is a handy shortcut for installing oh-my-zsh plugins. They can be loaded using `zgen load` too with a significantly longer format.
#### Load oh-my-zsh base
It's a good idea to load the base components before specifying any plugins.

    zgen oh-my-zsh

#### Load oh-my-zsh plugins

    zgen oh-my-zsh <location>

#### Example

    zgen oh-my-zsh
    zgen oh-my-zsh plugins/git
    zgen oh-my-zsh plugins/sudo
    zgen oh-my-zsh plugins/command-not-found
    zgen oh-my-zsh themes/arrow

### Prezto

#### Load Prezto

    zgen prezto

This will create a symlink in the `ZSHDOT` or `HOME` directory. This is needed by prezto.

**Note**: When `zgen prezto` is used with `zgen oh-my-zsh` together, `zgen prezto` should be **put behind** the other. Or prompt theme from prezto may not display as expected.

#### Load prezto plugins

    zgen prezto <modulename>

This uses the Prezto method for loading modules.

**Note**: Some modules from prezto are enabled by default. Use `ZGEN_PREZTO_LOAD_DEFAULT=0` to disable this behavior.

#### Load a repo as Prezto plugins

    zgen pmodule <reponame> <branch>

This uses the Prezto method for loading the module. It creates a symlink and calls `pmodule`.

#### Set prezto options

    zgen prezto <modulename> <option> <value(s)>

This must be used before the module is loaded. Or if the default modules should be loaded (default) these settings must be done before the `zgen prezto` command. `module` is prepended if the name does not start with `module`, `prezto` or a `*`, `prezto` is prepended if it does not start with `prezto`.

### General zgen functions

#### Load plugins and completions

    zgen load <repo> [location] [branch]

Zgen tries to source any scripts from `location` using a "very smart matching logic". If it fails to find any, it will appends `location` to `$fpath`.

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

#### Bulk load plugins

    zgen loadall <plugins>

Please see example `.zshrc` for usage.

#### Generate init script
    zgen save

It is recommended to save the plugin sourcing part to a static init script so we don't have to go through the time consuming installing/updating part every time we start the shell (or source .zshrc)

#### Remove init script
    zgen reset

Removes the init script so it will be created next time you start the shell. You must run this every time you add or remove plugins to trigger the changes.

This will not remove the plugins physically from disk.

#### Check for an init script
    zgen saved
Returns 0 if an init script exists.

#### Update all plugins and reset
    zgen update

Pulls updates on every plugin repository and removes the init script.

#### Update zgen
    zgen selfupdate

#### Watch files for modifications
You can automate the process of running `zgen reset` by specifying a list of files to `ZGEN_RESET_ON_CHANGE`. These files will be checked and if a change is detected zgen reset is called.

```zsh
ZGEN_RESET_ON_CHANGE=(${HOME}/.zshrc ${HOME}/.zshrc.local)
```

## Notes
Be aware that `zgen` tries to handle [`compinit`][compinit] for you to allow for the fastest possible initialization times. However, this functionality will be disabled if you've already called `compinit` yourself before sourcing `zgen.zsh`. Alternatively, you can disable it yourself by disabling `$ZGEN_AUTOLOAD_COMPINIT`.

  [compinit]: <http://zsh.sourceforge.net/Doc/Release/Completion-System.html#Use-of-compinit> "Zsh manual 20.2.1: Use of compinit"

## Example .zshrc

```zsh
# load zgen
source "${HOME}/.zgen/zgen.zsh"

# if the init scipt doesn't exist
if ! zgen saved; then
    echo "Creating a zgen save"

    zgen oh-my-zsh

    # plugins
    zgen oh-my-zsh plugins/git
    zgen oh-my-zsh plugins/sudo
    zgen oh-my-zsh plugins/command-not-found
    zgen load zsh-users/zsh-syntax-highlighting
    zgen load /path/to/super-secret-private-plugin

    # bulk load
    zgen loadall <<EOPLUGINS
        zsh-users/zsh-history-substring-search
        /path/to/local/plugin
EOPLUGINS
    # ^ can't indent this EOPLUGINS

    # completions
    zgen load zsh-users/zsh-completions src

    # theme
    zgen oh-my-zsh themes/arrow

    # save all to init script
    zgen save
fi
```

### Example .zshrc for prezto use
Here is a partial example how to work with prezto

```zsh
...
    echo "Creating a zgen save"

    # prezto options
    zgen prezto editor key-bindings 'emacs'
    zgen prezto prompt theme 'sorin'

    # prezto and modules
    zgen prezto
    zgen prezto git
    zgen prezto command-not-found
    zgen prezto syntax-highlighting

    # plugins
    zgen load /path/to/super-secret-private-plugin
....

```

## Other resources

The [awesome-zsh-plugins](https://github.com/unixorn/awesome-zsh-plugins) list contains many zgen-compatible zsh plugins & themes that you may find useful.

There's a quickstart kit for using zsh and zgen at [zsh-quickstart-kit](https://github.com/unixorn/zsh-quickstart-kit) that guides you through setting up zgen and includes a sampler of useful plugins.

The [autoupdate-zgen](https://github.com/unixorn/autoupdate-zgen) plugin will enable your zgen to periodically update itself and your list of plugins.

## Alternatives

- [antigen](https://github.com/zsh-users/antigen) - popular and mature
- [zplug](https://github.com/b4b4r07/zplug) - well performing and has a fancy UI
