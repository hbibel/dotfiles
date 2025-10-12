export def install [--verbose] {
  if  (pacman -Q cosmic-session | complete | get exit_code) == 0 {
    if $verbose {
      print "already installed: Cosmic"
    }
  } else {
    print "Installing COSMIC desktop ..."
    sudo pacman -S --noconfirm cosmic
  }

  if (systemctl is-enabled cosmic-greeter | complete | get stdout | str trim) == "not-found" {
    print "WARNING: Cosmic greeter service not found!"
  } else if (systemctl is-enabled cosmic-greeter | complete | get stdout | str trim) == "enabled" {
    if $verbose {
      print "Cosmic greeter service is already enabled"
    }
  } else {
    print "Cosmic greeter service is inactive, enabling ..."
    sudo systemctl enable cosmic-greeter
  }
}
