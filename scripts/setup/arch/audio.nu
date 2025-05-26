export def setup [] {
  let service_status = sudo systemctl status pipewire-pulse | complete
  if ($service_status.exit_code) == 0 {
    log info "pipewire-pulse already set up"
    return
  } else if ($service_status.exit_code) == 3 {
    sudo pacman -S --noconfirm pipewire-audio pipewire-pulse
    systemctl --user enable pipewire-pulse.service
    systemctl --user start pipewire-pulse.service
    return
  } else if ($service_status.exit_code) != 4 {
    let err_output = (sudo systemctl status service | complete)
    log error $"querying service service status returned an error: ($err_output)"
    return
  }

  # run `pactl info` to check
}
