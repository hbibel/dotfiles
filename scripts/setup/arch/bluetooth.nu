use ~/scripts/utils/linux.nu [
  service_status,
  SERVICE_STATUS_RUNNING,
  SERVICE_STATUS_NOT_FOUND,
  SERVICE_STATUS_INACTIVE
]

export def setup [--verbose] {
  let bluetooth_status = service_status bluetooth
  if $bluetooth_status == $SERVICE_STATUS_RUNNING {
    if $verbose {
      print "bluetooth already set up"
    }
    return
  }

  if $bluetooth_status == $SERVICE_STATUS_NOT_FOUND {
    print "Setting up Bluetooth ..."
    sudo pacman -S --noconfirm bluez bluez-utils
    sudo systemctl enable bluetooth
    sudo systemctl start bluetooth
  } else if $bluetooth_status == $SERVICE_STATUS_INACTIVE {
    print "BLuetooth inactive, enabling ..."
    sudo systemctl enable bluetooth
    sudo systemctl start bluetooth
  } else {
    print $"unhandled bluetooth status: ($bluetooth_status)"
  }
}
