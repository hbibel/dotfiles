export def --env init [] {
  source ~/secrets.nu

  $env.BIN_PATH = $"($env.HOME)/.local/bin"

  path add $"($env.HOME)/.cargo/bin"

  if ($nu.os-info.name == "macos") {
    path add "/opt/homebrew/bin"
    path add "/usr/local/go/bin"
    path add "/nix/var/nix/profiles/default/bin"
  }

  path add $env.BIN_PATH
}

export def in-home-network [] {
  let nodename = uname | get nodename
  $nodename == "obsidian"
}
