use std/log

use ~/scripts/utils/linux.nu [
  service_status,
  SERVICE_STATUS_RUNNING,
  SERVICE_STATUS_NOT_FOUND,
  SERVICE_STATUS_INACTIVE
]

export def setup [] {
  let bluetooth_status = service_status bluetooth
  if $bluetooth_status == $SERVICE_STATUS_RUNNING {
    log info "bluetooth already set up"
    return
  }

  if $bluetooth_status == $SERVICE_STATUS_NOT_FOUND {
    sudo pacman -S --noconfirm bluez bluez-utils
    sudo systemctl enable bluetooth
    sudo systemctl start bluetooth
  } else if $bluetooth_status == $SERVICE_STATUS_INACTIVE {
    sudo systemctl enable bluetooth
    sudo systemctl start bluetooth
  } else {
    log error $"unhandled bluetooth status: ($bluetooth_status)"
  }
}
