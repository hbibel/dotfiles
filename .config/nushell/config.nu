# const NU_LIB_DIRS = [
#   '~/scripts'
# ]
# use utils/goose *

use std/util "path add"

export use ~/scripts/workflows/dotfiles.nu
export use ~/scripts/workflows/fv.nu
export use ~/scripts/workflows/proj.nu
export use ~/scripts/workflows/version_control.nu wt

export use ~/scripts/utils/linux.nu

export use ~/scripts/setup/software/neovim.nu
export use ~/scripts/setup/software/fnm.nu [init-fnm]

alias la = ls -la
alias fg = job unfreeze

path add $"($env.HOME)/.cargo/bin"

if ($nu.os-info.name == "macos") {
  path add "/opt/homebrew/bin"
  path add "/usr/local/go/bin"
}

# TODO this path should be an environment variable and used in other scripts
# and neovim config, instead of hardcoded everywhere
path add $"($env.HOME)/.local/bin"
path add $"($env.HOME)/bin"

$env.config.show_banner = false

init-fnm
