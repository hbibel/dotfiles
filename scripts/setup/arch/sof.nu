use std/log

# sof-firmware is audio infrastructure required on my HP Spectre x360
# (and many other laptops)

export def install [] {
  if (pacman -Q sof-firmware | complete | get exit_code) == 0 {
    log info "already installed: sof-firmware"
    return
  }
  sudo pacman -S --noconfirm sof-firmware
}
