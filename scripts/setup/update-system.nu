use ~/scripts/setup/arch.nu

def main [] {
  mkdir ($env.HOME | path join ".local/bin")
  if (which funstall | is-empty) {
    rm -f /tmp/install-funstall.nu
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

  (
    funstall update --install-missing --packages=([
      "delta"
      "discord"
      "edge"
      "fzf"
      "joplin"
      "keepass"
      "neovim"
      "nerd-fonts"
      "nix"
      "ripgrep"
      "wezterm"
      "wget"
      "wl-clipboard"
      "zsh"
    ] | str join ',')
  )
}
