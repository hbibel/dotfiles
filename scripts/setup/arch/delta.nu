use std/log

export def install [] {
  if not (which delta | is-empty) {
    log info "already installed: delta"
    return
  }
  sudo pacman -S --noconfirm git-delta
}
