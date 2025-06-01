use std/log

export def setup [] {
  let bluetooth_status = sudo systemctl status bluetooth | complete
  if ($bluetooth_status.exit_code) == 0 {
    log info "bluetooth already set up"
    return
  } else if ($bluetooth_status.exit_code) == 3 {
    sudo systemctl enable bluetooth
    sudo systemctl start bluetooth
    return
  } else if ($bluetooth_status.exit_code) != 4 {
    let err_output = (sudo systemctl status bluetooth | complete)
    log error $"querying bluetooth service status returned an error: ($err_output)"
    return
  }
  sudo pacman -S --noconfirm bluez bluez-utils
  sudo systemctl enable bluetooth
  sudo systemctl start bluetooth
}
