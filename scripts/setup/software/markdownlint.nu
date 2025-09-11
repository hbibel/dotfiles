# depends on fnm
export def install [] {
  let install_dir = ($env.HOME | path join "software/markdownlint")
  mkdir $install_dir
  cd $install_dir

  echo "22.19.0" | save ".node-version"
  fnm use --install-if-missing

  npm install markdownlint-cli2 --save

  (
    ln -s
    ($install_dir | path join "node_modules/.bin/markdownlint-cli2")
    ($env.HOME | path join ".local/bin/markdownlint-cli2")
  )
}
