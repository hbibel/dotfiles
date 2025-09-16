use ~/scripts/system/environment.nu

export def mount-illmatic [] {
  if not (environment in-home-network) {
    error make { msg: "Can't mount illmatic, not in home network" }
  }

  (
    sudo mount
    --mkdir
    -t cifs
    //illmatic/homes/bossman /mnt/illmatic
    -o $"uid=(id -u),gid=(id -g),username=($env.ILLMATIC_USERNAME),password=($env.ILLMATIC_PASSWORD),iocharset=utf8"
  )
}

export alias battlvl = cat /sys/class/power_supply/BAT0/capacity

export alias la = ls -la

export alias fg = job unfreeze
