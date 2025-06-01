use std/log

export def install [] {
  if (pacman -Q samba | complete | get exit_code) == 0 {
    log info "already installed: samba"
    return
  }
  sudo pacman -S --noconfirm samba
}
