# const NU_LIB_DIRS = [
#   '~/scripts'
# ]
# use utils/goose *

export use ~/scripts/workflows/proj.nu
export use ~/scripts/utils/linux.nu

alias la = ls -la

def --wrapped dotfiles [...args: string] {
  let git_dir = $env.HOME | path join ".dotfiles"
  (
    /usr/bin/git
    $"--git-dir=($git_dir)"
    $"--work-tree=($env.HOME)"
    ...$args
  )
}
