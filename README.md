# Hab

> While on Mars, the crew will be living in an artificial habitat, or _Hab_ for
> short.

This Oh My ZSH plugin automatically loads OS environment variables defined in
the file `.envrc` if it's found while changing directories.

## Small example

```bash
~ $ cd my_project
[SUCCESS]  Loaded hab [/home/user/my_project/.envrc]
~/my_project $ echo "$MY_HOSTNAME"
https://my.hab
~/my_project $ cat .envrc
export MY_HOSTNAME="https://my.hab"
```

## Loading special habs

By default, _Hab_ will try to load `.envrc` file, but it's possible to have
several of those files for different purposes e.g:

- `.envrc.prod` for production OS variables.
- `.envrc.test` for testing OS variables.
- `.envrc` for development variables.

_Hab_ will load the development variables by default, but it can load the other
files using the following command:

```bash
~/my_project $ load_hab prod # where `prod` is the extension of the file.
[SUCCESS]  Loaded hab [/home/user/my_project/.envrc.prod]
```

## Base _Hab_ name

By default, the _Hab_ file is always `.envrc`, but this can be change by
changing the value of the variable `$HAB_BASE` in your `$HOME/.zshrc` file e.g:

```bash
export HAB_BASE=".hab_base"
```

## Installation

Just clone _Hab_ as follows:

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

## Author

Alexander de Sousa.

## License

`Hab` is released under the MIT License. See the LICENSE file for further
details.
