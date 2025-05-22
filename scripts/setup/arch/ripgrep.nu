use std/log

export def install [] {
  if not (which rg | is-empty) {
    log info "already installed: ripgrep"
    return
  }
  sudo pacman -S --noconfirm ripgrep
}
