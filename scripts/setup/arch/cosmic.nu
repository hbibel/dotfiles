use std/log

export def install [] {
  if  (pacman -Q cosmic-session | complete | get exit_code) == 0 {
    log info "already installed: Cosmic"
  } else {
    sudo pacman -S --noconfirm cosmic
  }

  if (systemctl is-enabled cosmic-greeter | complete | get stdout | str trim) == "not-found" {
    log warning "Cosmic greeter service not found!"
  } else if (systemctl is-enabled cosmic-greeters | complete | get stdout | str trim) == "enabled" {
    log info "Cosmic greeter service is already enabled"
  } else {
    sudo systemctl enable cosmic-greeter
  }
}
