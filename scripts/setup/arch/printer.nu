use ~/scripts/utils/linux.nu [
  service_status,
  SERVICE_STATUS_RUNNING,
  SERVICE_STATUS_NOT_FOUND,
  SERVICE_STATUS_INACTIVE
]

export def setup [--verbose] {
  setup_service avahi avahi-daemon --verbose=$verbose
  setup_service cups cups --verbose=$verbose

  if not (which gs | is-empty) {
    if $verbose {
      print "already installed: ghostscript"
    }
  } else {
    sudo pacman -S --noconfirm ghostscript
  }

  if ("/usr/bin/saned" | path exists) {
    if $verbose {
      print "already installed: sane"
    }
  } else {
    print "Installing sane ..."
    sudo pacman -S --noconfirm sane
  }

  if not (which simple-scan | is-empty) {
    if $verbose {
      print "already installed: simple-scan"
    }
  } else {
    print "Installing simple-scan ..."
    sudo pacman -S --noconfirm simple-scan
  }
}

def setup_service [package_name: string, service_name: string, --verbose] {
  let service_status = service_status $service_name
  if $service_status == $SERVICE_STATUS_RUNNING {
    if $verbose {
      print $"($service_name) already set up"
    }
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
    print $"unhandled ($service_name) status: ($service_status)"
  }
}

export def add_printers [] {
  let devices = (lpinfo -v | lines | parse "{type} {uri}")
  
  # Filter out generic protocol entries and keep actual printer URIs
  let printers = ($devices | where uri !~ "^(beh|ipp|ipps|http|lpd|https|socket|smb)$")
  
  if ($printers | length) == 0 {
    print "No network printers found."
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
    print "No printers to be added."
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
      
      print $"Adding printer: ($printer_name) with URI: ($uri)"
      
      try {
        lpadmin -p $printer_name -E -v $uri -m everywhere
        print $"Successfully added ($printer_name)"
      } catch {
        print $"Failed to add ($printer_name)"
      }
    } else {
      print $"Invalid selection: ($index + 1)"
    }
  }
}
