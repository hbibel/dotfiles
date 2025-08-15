export use ~/scripts/workflows/proj.nu

export def --wrapped main [...args: string] {
  let git_dir = $env.HOME | path join ".dotfiles"
  (
    /usr/bin/git
    $"--git-dir=($git_dir)"
    $"--work-tree=($env.HOME)"
    ...$args
  )
}

export def --env edit [
  category?: string,
] {
  if $category == null {
    proj edit ($env.HOME | path join "scripts")
  } else {
    match ($category | str trim) {
      "config.nu" => (proj edit ($env.HOME | path join ".config/nushell") --file config.nu),
      "nvim" => (proj edit ($env.HOME | path join ".config/nvim")),
      _ => {
        error make {msg: $"Usage: dotfiles edit \(config.nu | nvim\); unknown category '($category)'", }
      },
    }
  }
}
