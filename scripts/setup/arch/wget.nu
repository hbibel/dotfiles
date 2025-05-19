use std/log

export def install [] {
  if not (which wget | is-empty) {
    log info "already installed: wget"
    return
  }

  sudo pacman -S --noconfirm wget
}
