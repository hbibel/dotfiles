use ~/scripts/utils/linux.nu

export def setup [] {
  use linux SERVICE_STATUS_RUNNING
  use linux SERVICE_STATUS_NOT_FOUND

  let service_status = linux get_service_status pipewire-pulse
  if $service_status == $SERVICE_STATUS_RUNNING {
    log info "pipewire-pulse already set up"
    return
  }

  if $service_status == $SERVICE_STATUS_NOT_FOUND {
    sudo pacman -S --noconfirm pipewire-audio pipewire-pulse
    systemctl --user enable pipewire-pulse.service
    systemctl --user start pipewire-pulse.service
  } else if $bluetooth_status == $SERVICE_STATUS_INACTIVE {
    systemctl --user enable pipewire-pulse.service
    systemctl --user start pipewire-pulse.service
  } else {
    log error $"unhandled pipewire-pulse status: ($service_status)"
  }

  # run `pactl info` to check manually
}
