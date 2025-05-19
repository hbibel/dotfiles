use std/log

export def install [] {
  if not (which keepass | is-empty) {
    log info "already installed: keepass"
    return
  }

  sudo pacman -S --noconfirm keepass
}
