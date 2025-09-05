use std/log

use ~/scripts/setup/software/python.nu

export def install [] {
  if not (which zubanls | is-empty) {
    log info "already installed: zubanls"
    return
  }

  let install_dir = ($env.HOME | path join "software/zuban")
  if ($install_dir | path exists) {
    rm -rf $install_dir
  }

  # The exact version for the venv we install the LSP in doesn't matter too
  # much, so I just choose an arbitrary one here
  let python_version = "python3.13"

  if (which $python_version | is-empty) {
    python install $python_version
  }

  ^$python_version -m venv $install_dir
  ^($install_dir | path join "bin/pip") install zuban

  let zuban_bin = ($install_dir | path join "bin/zuban")
  ln -s $zuban_bin ($env.HOME | path join ".local/bin/zuban")
}
