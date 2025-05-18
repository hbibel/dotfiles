use std/log

export def install [] {
  if not (which yay | is-empty) {
    log info "already installed: yay"
    return
  }

  cd /tmp
  sudo pacman -S --noconfirm --needed git base-devel
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm

  yay -Y --gendb
}
