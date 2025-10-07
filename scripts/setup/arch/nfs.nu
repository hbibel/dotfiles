export def install [--verbose] {
  if (pacman -Q nfs-utils | complete | get exit_code) == 0 {
    if $verbose {
      print "already installed: nfs-utils"
    }
    return
  }
  print "Installing nfs-utils"
  sudo pacman -S --noconfirm nfs-utils
}
