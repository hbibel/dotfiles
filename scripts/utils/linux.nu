export const SERVICE_STATUS_NOT_FOUND = "not found"
export const SERVICE_STATUS_INACTIVE = "inactive"
export const SERVICE_STATUS_RUNNING = "running"
export const SERVICE_STATUS_EXITED = "exited"
export const SERVICE_STATUS_FAILED = "failed"

export def get_service_status [service_name: string] {
  let status_output = sudo systemctl show $service_name | complete | get stdout
  let status = (
    $status_output |
    lines |
    parse '{k}={v}' |
    reduce --fold {} {|elem, acc| $acc | insert ($elem | get k) ($elem | get v)}
  )

  let load_state = $status | get LoadState
  let active_state = $status | get ActiveState
  let substate = $status | get SubState

  if $load_state == "not-found" {
    return $SERVICE_STATUS_NOT_FOUND
  } else if $load_state == "loaded" and $active_state == "inactive" {
    return $SERVICE_STATUS_INACTIVE
  } else if $load_state == "loaded" and $active_state == "active" and $substate == "running" {
    return $SERVICE_STATUS_RUNNING
  } else if $load_state == "loaded" and $active_state == "active" and $substate == "exited" {
    return $SERVICE_STATUS_EXITED
  } else if $load_state == "failed" or $active_state == "failed" {
    return $SERVICE_STATUS_FAILED
  }

  $"other status: ({
    load_state: $load_state,
    active_state: $active_state,
    substate: $substate
  })"
}
