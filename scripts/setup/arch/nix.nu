use std/log

export def install [] {
  cd /tmp
  if not (which nix-shell | is-empty) {
    log info "already installed: nix"
  }
  curl --output nix-install.sh --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install
  sh nix-install.sh --daemon --yes
}
