export def setup [--verbose] {
  if (pacman -Q davfs2 | complete | get exit_code) == 0 {
    if $verbose {
      print "already installed: davfs2"
    }
  } else {
    sudo pacman -S --noconfirm davfs2
  }

  sudo mkdir /mnt/illmatic/family
  check-fstab "family"
  sudo mkdir /mnt/illmatic/hannes
  check-fstab "hannes"
}

def check-fstab [subdir: string] {
  let base_url = $env.ILLMATIC_BASE_URL
  let options = [
    "rw"
    $"uid=(id -u)"
    $"gid=(id -g)"
    "x-systemd.automount"
    "x-systemd.mount-timeout=30"
    "_netdev"
  ]

  let fstab_line_parts = [
    $"https://($base_url)/($subdir)"
    $"/mnt/illmatic/($subdir)"
    "davfs"
    ($options | str join ",")
    "0"
    "0"
  ]
  let fstab_line = $fstab_line_parts | str join " "

  if (not ($fstab_line in (open /etc/fstab | lines))) {
    # Just printing a warning here, not editing /etc/fstab in order not to risk
    # ruining my fstab file
    print (
      "Warning: /etc/fstab does not contain or contains an outdated " +
      $"line for NAS subdirectory ($subdir). Edit /etc/fstab and place\n  " +
      $fstab_line +
      "\ninside. Also create a secrets file /etc/davfs2/secrets with\n  " +
      $"https://($base_url)/($subdir) user password"
    )
  }
}
