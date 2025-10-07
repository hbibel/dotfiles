export def install [--verbose] {
  if (pacman -Q samba | complete | get exit_code) == 0 {
    if $verbose {
      print "already installed: samba"
    }
    return
  }
  print "Installing samba ..."
  sudo pacman -S --noconfirm samba
}
