use ~/scripts/setup/arch.nu

def main [] {
  if (which funstall | is-empty) {
    (
      ^curl
        --silent
        --show-error
        --location
        https://raw.githubusercontent.com/hbibel/funstall/refs/heads/main/install.nu
        -o /tmp/install-funstall.nu
    )
    (
      nu /tmp/install-funstall.nu
      --pyenv-root ($env.HOME | path join "software/python")
      --install-dir ($env.HOME | path join "software/funstall")
    )
    rm /tmp/install-funstall.nu
  }

  if (uname | get kernel-release | str contains "arch") {
    arch setup
  }

  # TODO funstall install --?? delta discord edge fonts fzf joplin keepass wezterm wget zsh neovim ripgrep nix
}
