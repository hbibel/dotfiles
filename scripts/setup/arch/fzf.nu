use std/log

export def install [] {
  if not (which fzf | is-empty) {
    log info "already installed: fzf"
    return
  }
  sudo pacman -S --noconfirm fzf
}
