use std/log

use ~/scripts/setup/software/python.nu

export def install [] {
  let install_dir = ($env.HOME | path join "software/python_lsp")
  mkdir $install_dir

  # The exact version for the venv we install the LSP in doesn't matter too
  # much, so I just choose an arbitrary one here
  let python_version = "python3.13.7"

  if (which $python_version | is-empty) {
    python install $python_version
  }

  let venv_dir = ($install_dir | path join "venv")
  rm -rf $venv_dir
  ^$python_version -m venv $venv_dir
  ^($venv_dir | path join "bin/pip") install python-lsp-server

  let pylsp_bin = ($install_dir | path join "venv")
  ln -s $pylsp_bin ($env.HOME | path join ".local/bin/pylsp")
}


