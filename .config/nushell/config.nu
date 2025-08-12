# const NU_LIB_DIRS = [
#   '~/scripts'
# ]
# use utils/goose *

use std/util "path add"

export use ~/scripts/workflows/proj.nu
export use ~/scripts/workflows/version_control.nu wt

export use ~/scripts/utils/linux.nu

alias la = ls -la

path add $"($env.HOME)/bin"

if ($nu.os-info.name == "macos") {
  path add "/opt/homebrew/bin"
}

$env.config.show_banner = false

def --wrapped dotfiles [...args: string] {
  let git_dir = $env.HOME | path join ".dotfiles"
  (
    /usr/bin/git
    $"--git-dir=($git_dir)"
    $"--work-tree=($env.HOME)"
    ...$args
  )
}
