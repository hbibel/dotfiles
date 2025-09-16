use std/util "path add"

# Set environment variables required for fnm to work properly. Also includes
# a shell hook to use a project-specific node version
export def --env init-fnm [] {
  if not (which fnm | is-empty) {
    ^fnm env --json | from json | load-env

    path add (
      $env.FNM_MULTISHELL_PATH |
      path join (if $nu.os-info.name == "windows" {""} else {"bin"})
    )
    $env.config.hooks.env_change.PWD = (
      $env.config.hooks.env_change.PWD? | append {
        condition: {|| [".nvmrc" ".node-version", "package.json"] | any {|el| $el | path exists}}
        code: {|| ^fnm use --silent-if-unchanged --install-if-missing}
      }
    )
  }
}

# requires unzip and curl
export def install [] {
  let install_dir = $env.HOME | path join "software/fnm"
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir $install_dir
  ln -s ($install_dir | path join "fnm") ($env.HOME | path join ".local/bin")
}
