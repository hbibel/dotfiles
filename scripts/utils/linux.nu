export const SERVICE_STATUS_NOT_FOUND = "not found"
export const SERVICE_STATUS_INACTIVE = "inactive"
export const SERVICE_STATUS_RUNNING = "running"
export const SERVICE_STATUS_EXITED = "exited"
export const SERVICE_STATUS_FAILED = "failed"

export def get_service_status [service_name: string] {
  mut status = get_service_status_tuple $service_name false
  mut load_state = $status | get load_state
  mut active_state = $status | get active_state
  mut sub_state = $status | get sub_state

  if $load_state == "not-found" {
    # service not found in kernel space, try again searching for user service
    $status = (get_service_status_tuple $service_name true)
    $load_state = $status | get load_state
    $active_state = $status | get active_state
    $sub_state = $status | get sub_state
  }

  if $load_state == "not-found" {
    return $SERVICE_STATUS_NOT_FOUND
  } else if $load_state == "loaded" and $active_state == "inactive" {
    return $SERVICE_STATUS_INACTIVE
  } else if $load_state == "loaded" and $active_state == "active" and $sub_state == "running" {
    return $SERVICE_STATUS_RUNNING
  } else if $load_state == "loaded" and $active_state == "active" and $sub_state == "exited" {
    return $SERVICE_STATUS_EXITED
  } else if $load_state == "failed" or $active_state == "failed" {
    return $SERVICE_STATUS_FAILED
  }

  $"other status: ($status)"
}

def get_service_status_tuple [service_name: string, user_space: bool] {
  let status_output = if $user_space {
    systemctl --user show $service_name | complete | get stdout
  } else {
    sudo systemctl show $service_name | complete | get stdout
  }
  let status = (
    $status_output |
    lines |
    parse '{k}={v}' |
    reduce --fold {} {|elem, acc| $acc | insert ($elem | get k) ($elem | get v)}
  )

  {
    load_state: ($status | get LoadState),
    active_state: ($status | get ActiveState),
    sub_state: ($status | get SubState),
  }
}
