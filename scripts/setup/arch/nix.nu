use std/log

export def install [] {
  cd /tmp
  if not (which nix | is-empty) {
    log info "already installed: nix"
    return
  }

  # Official installer:
  # curl --output nix-install.sh --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install
  # sh nix-install.sh --daemon --yes

  # Better installer:
  # https://github.com/DeterminateSystems/nix-installer
  curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate --no-confirm
}
