# Hab

> While on Mars, the crew will be living in an artificial habitat, or _Hab_ for
> short.

This Oh My ZSH plugin automatically loads OS environment variables defined in
the file `.envrc` if it's found while changing directories.

## Small example

```bash
~ $ cd my_project
[SUCCESS]  Loaded hab [/home/user/my_project/.envrc]
my_project $ echo "$MY_HOSTNAME"
https://my.hab
my_project $ cat .envrc
export MY_HOSTNAME="https://my.hab"
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
