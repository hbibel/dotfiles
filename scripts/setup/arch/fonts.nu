use std/log

export def install [] {
  if  (pacman -Q noto-fonts-emoji | complete | get exit_code) == 0 {
    log info "already installed: noto-fonts-emoji"
    return
  }
  sudo pacman -S --noconfirm noto-fonts-emoji
}
