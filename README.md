# Hab

> While on Mars, the crew will be living in an artificial habitat, or _Hab_ for
> short.

`Hab` is an [Oh My ZSH](https://ohmyz.sh/) plugin that loads/unloads OS
enviroment variables and functions automatically when:

- Changing directories
- Opening new TMUX shells.

## Small example

Given the following `.envrc` file in the folder `my_project`:

```bash
# file: /home/user/my_project/.envrc
export MY_HOSTNAME="https://my.hab"

function clean_build() {
  rm -rf "$(pwd)/_build" 2> /dev/null
  echo "All cleaned!"
}
```

Then:

1. Loads it when `cd`ing into `my_project`:
   ```bash
   ~ $ cd my_project
   [SUCCESS]  Loaded hab [/home/user/my_project/.envrc]

   ~/my_project $ echo "$MY_HOSTNAME"
   https://my.hab

   ~/my_project $ clean_build
   All cleaned!
   ```

2. Unloads it when `cd`ing out of `my_project`

   ```bash
   ~/my_project $ cd ..
   [WARN]  Unloaded variable MY_HOSTNAME
   [WARN]  Unloaded function clean_build
   ```

## Helper commands

Though everything happens automatically, this plugin provides the following
command helpers:

- `hab_load [<extension>]` to manually load a `.envrc[.<extension>]` file.
- `hab_unload` to manually unload current `.envrc[.<extension>]` file.
- `hab_update` to manually update the plugin.

## Loading special habs

By default, `Hab` will try to load `.envrc` file, but it's possible to have
several of those files for different purposes e.g:

- `.envrc.prod` for production OS variables.
- `.envrc.test` for testing OS variables.
- `.envrc` for development variables.

`Hab` will load the development variables by default, but it can load the other
files using the following command:

```bash
~/my_project $ hab_load prod # it'll load .envrc.prod
[SUCCESS]  Loaded hab [/home/user/my_project/.envrc.prod]
```

## Base `Hab` name

The `Hab` file is `.envrc` by default. However this can be customized by
changing the value of the variable `$HAB_BASE` in your `$HOME/.zshrc` file e.g:

```bash
export HAB_BASE=".hab_base"
```

## Installation

Just clone `Hab` as follows:

```bash
~ $ git clone "https://github.com/alexdesousa/hab.git" "$ZSH_CUSTOM/plugins/hab"
```

And add the hab to your `plugins` in `$HOME/.zshrc` file:

```bash
plugins=(
  git
  hab
)
```

> Important: when updating you can run the following:
>
> ```bash
> cd `$ZSH_CUSTOM/plugins/hab` && git pull origin master
> ```

## Author

Alexander de Sousa.

## License

`Hab` is released under the MIT License. See the LICENSE file for further
details.
