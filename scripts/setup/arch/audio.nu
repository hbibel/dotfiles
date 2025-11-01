use ~/scripts/utils/linux.nu [
  service_status,
  SERVICE_STATUS_RUNNING,
  SERVICE_STATUS_NOT_FOUND,
  SERVICE_STATUS_INACTIVE
]

export def setup [--verbose] {
  setup-pipewire --verbose=$verbose
  install-sof-firmware --verbose=$verbose
}

def setup-pipewire [--verbose] {
  let service_status = service_status pipewire-pulse
  if $service_status == $SERVICE_STATUS_RUNNING {
    if $verbose {
      print "pipewire-pulse already set up"
    }
    return
  }

  if $service_status == $SERVICE_STATUS_NOT_FOUND {
    print "Setting up pipewire ..."
    sudo pacman -S --noconfirm pipewire-audio pipewire-pulse
    systemctl --user enable pipewire-pulse.service
    systemctl --user start pipewire-pulse.service
  } else if $service_status == $SERVICE_STATUS_INACTIVE {
    print "pipewire-pulse is inactive, enabling ..."
    systemctl --user enable pipewire-pulse.service
    systemctl --user start pipewire-pulse.service
  } else {
    error make { msg: $"unhandled pipewire-pulse status: ($service_status)" }
  }

  # run `pactl info` to check manually
}

def install-sof-firmware [--verbose] {
  if (pacman -Q sof-firmware | complete | get exit_code) == 0 {
    if $verbose {
      log info "already installed: sof-firmware"
    }
    return
  }
  print "Installing sof-firmware..."
  sudo pacman -S --noconfirm sof-firmware
}
