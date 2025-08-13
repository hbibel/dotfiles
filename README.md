# How to Checkout my Dotfiles

## 1. Create alias

Create an alias in your shell so you don't have to retype the whole command all
the time:

```nu
# Nushell
def --wrapped dotfiles [...args: string] {
  let git_dir = $env.HOME | path join ".dotfiles"
  (
    /usr/bin/git
    $"--git-dir=($git_dir)"
    $"--work-tree=($env.HOME)"
    ...$args
  )
}
```

```sh
# (ba|z)sh
alias dotfiles='/usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'
```

## 2. Add repo to gitignore to avoid recursion issues

```nu
# Nushell
echo ".dotfiles" | save .gitignore --append
```

```sh
# (ba|z)sh
echo ".dotfiles" >> .gitignore
```

## 3. Clone the repo

First, backup any already existing configuration files, e.g.
`mv ~/.zshrc ~/.zshrc.bak`.

```nu
# Nushell
let dotfiles_dir = $env.home | path join ".dotfiles"
git clone --bare <git-repo-url> $dotfiles_dir
```

```sh
# (ba|z)sh
git clone --bare <git-repo-url> $HOME/.dotfiles
```

```sh
dotfiles checkout
dotfiles config --local status.showUntrackedFiles no
```
