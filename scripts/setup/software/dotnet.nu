use std/log

# depends on: curl, bash
export def install [] {
  if not (which dotnet | is-empty) {
    log info "already installed: dotnet"
    return
  }

  let wdir = ($env.HOME | path join "tmp/dotnet-install")
  mkdir $wdir
  cd $wdir

  ^curl --fail --location --remote-name https://dot.net/v1/dotnet-install.sh

  let install_dir = ($env.HOME | path join "software/dotnet")
  (
    bash dotnet-install.sh
    --runtime dotnet
    --channel LTS
    --install-dir $install_dir
    --no-path
  )
  ln -s ($install_dir | path join "dotnet") ($env.HOME | path join "bin/dotnet")

  cd
  rm -r $wdir
}
