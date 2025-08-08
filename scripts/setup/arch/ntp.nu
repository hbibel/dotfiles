use std/log

export def setup [] {
  let ntp_status_line = timedatectl status | lines | where { str contains 'NTP service:' } | get 0
  let ntp_status = $ntp_status_line | split words | last
  if $ntp_status == "active" {
    log info "NTP is already active"
  } else if ($ntp_status == "inactive") {
    sudo timedatectl set-ntp true
  } else {
    error make { msg: $"Can't interpret status line '($ntp_status_line | str trim)'" }
  }
}
