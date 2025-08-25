use std/log

# depends on: dotnet
export def install [] {
  let install_dir = ($env.HOME | path join "software/bicep_lsp")
  mkdir $install_dir

  let dll_file = ($install_dir | path join "Bicep.LangServer.dll")
  if ($dll_file | path exists) {
    log info "already installed: bicep LSP"
    return
  }

  let wdir = ($env.HOME | path join "tmp/bicep-lsp-install")
  mkdir $wdir
  cd $wdir

  (
    ^curl
    --fail
    --location
    --remote-name
    "https://github.com/Azure/bicep/releases/latest/download/bicep-langserver.zip"
  )
  unzip -d $install_dir "bicep-langserver.zip"

  cd
  rm -rf $wdir
}

