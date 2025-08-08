use std/log

export def install [] {
  if not (which discord | is-empty) {
    log info "already installed: discord"
    return
  }

  sudo pacman -S --noconfirm discord
}
