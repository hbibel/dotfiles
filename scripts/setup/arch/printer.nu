use std/log

use ~/scripts/utils/linux.nu [
  service_status,
  SERVICE_STATUS_RUNNING,
  SERVICE_STATUS_NOT_FOUND,
  SERVICE_STATUS_INACTIVE
]

export def setup [] {
  setup_service avahi avahi-daemon
  setup_service cups cups

  if not (which gs | is-empty) {
    log info "already installed: ghostscript"
  } else {
    sudo pacman -S --noconfirm ghostscript
  }

  if ("/usr/bin/saned" | path exists) {
    log info "already installed: sane"
  } else {
    sudo pacman -S --noconfirm sane
  }

  if not (which simple-scan | is-empty) {
    log info "already installed: simple-scan"
  } else {
    sudo pacman -S --noconfirm simple-scan
  }

}

def setup_service [package_name: string, service_name: string] {
  let service_status = service_status $service_name
  if $service_status == $SERVICE_STATUS_RUNNING {
    log info $"($service_name) already set up"
    return
  }

  if $service_status == $SERVICE_STATUS_NOT_FOUND {
    sudo pacman -S --noconfirm $package_name
    sudo systemctl enable $service_name
    sudo systemctl start $service_name
    add_printers
  } else if $service_status == $SERVICE_STATUS_INACTIVE {
    sudo systemctl enable $service_name
    sudo systemctl start $service_name
    add_printers
  } else {
    log error $"unhandled ($service_name) status: ($service_status)"
  }
}

export def add_printers [] {
  let devices = (lpinfo -v | lines | parse "{type} {uri}")
  
  # Filter out generic protocol entries and keep actual printer URIs
  let printers = ($devices | where uri !~ "^(beh|ipp|ipps|http|lpd|https|socket|smb)$")
  
  if ($printers | length) == 0 {
    log info "No network printers found."
    return
  }
  
  print "Available printers to add:"
  $printers | enumerate | each {|item| 
    let index = ($item.index + 1)
    print $"($index). ($item.item.uri)"
  }
  
  print ""
  let selection = (input "Enter printer numbers to add (e.g., 1,3,5): ")
  let indices = ($selection | split row "," | each {|x| ($x | str trim | into int) - 1})

  if ($indices | length) == 0 {
    log info "No printers to be added."
    return
  }
    
  for index in $indices {
    if $index >= 0 and $index < ($printers | length) {
      let printer = ($printers | get $index)
      let uri = $printer.uri
      
      let printer_name = if ($uri | str starts-with "dnssd://") {
        ($uri | parse -r "dnssd://(?P<name>[^._]+)" | get name.0 | url decode)
      } else if ($uri | str starts-with "socket://") {
        let ip = ($uri | str replace "socket://" "")
        $"Printer_($ip | str replace "." "_")"
      } else {
        $"Printer_($index + 1)"
      }
      let printer_name = (
        $printer_name |
        str replace --all " " "_" |
        str replace --all "/" "_" |
        str replace --all "#" "_"
      )
      
      log info $"Adding printer: ($printer_name) with URI: ($uri)"
      
      try {
        lpadmin -p $printer_name -E -v $uri -m everywhere
        log info $"Successfully added ($printer_name)"
      } catch {
        log error $"Failed to add ($printer_name)"
      }
    } else {
      log error $"Invalid selection: ($index + 1)"
    }
  }
}
