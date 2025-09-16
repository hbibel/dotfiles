use std/util "path add"

export use ~/scripts/workflows/dotfiles.nu
export use ~/scripts/workflows/fv.nu
export use ~/scripts/workflows/proj.nu
export use ~/scripts/workflows/version_control.nu wt
export use ~/scripts/workflows/code-review.nu

export use ~/scripts/utils/linux.nu

export use ~/scripts/setup/software/neovim.nu
export use ~/scripts/setup/software/fnm.nu [init-fnm]

export use ~/scripts/system/commands.nu *

use ~/scripts/system/environment.nu

environment init

$env.config.show_banner = false

init-fnm
