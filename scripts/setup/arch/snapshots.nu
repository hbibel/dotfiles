use ~/scripts/utils/linux.nu ensure-installed

def subvolumes [] {
  [
    {
      name: "root",
      subvolume_mountpoint: "/",
      config: '
SUBVOLUME="/"
FSTYPE="btrfs"

BACKGROUND_COMPARISON="yes"

# Clean up if there is more than 50 snapshots
NUMBER_CLEANUP="yes"
NUMBER_MIN_AGE="3600"
NUMBER_LIMIT="30"
NUMBER_LIMIT_IMPORTANT="10"

# create hourly snapshots and keep the last 10 hourly, daily, ...
TIMELINE_CREATE="yes"
TIMELINE_CLEANUP="yes"
TIMELINE_MIN_AGE="3600"
TIMELINE_LIMIT_HOURLY="10"
TIMELINE_LIMIT_DAILY="10"
TIMELINE_LIMIT_WEEKLY="0"
TIMELINE_LIMIT_MONTHLY="3"
TIMELINE_LIMIT_QUARTERLY="0"
TIMELINE_LIMIT_YEARLY="0"

EMPTY_PRE_POST_CLEANUP="yes"
EMPTY_PRE_POST_MIN_AGE="3600"
',
    },
    {
      name: "home",
      subvolume_mountpoint: "/home",
      config: '
SUBVOLUME="/home"
FSTYPE="btrfs"

BACKGROUND_COMPARISON="yes"

# Clean up if there is more than 50 snapshots
NUMBER_CLEANUP="yes"
NUMBER_MIN_AGE="3600"
NUMBER_LIMIT="50"
NUMBER_LIMIT_IMPORTANT="10"

# create hourly snapshots and keep the last 10 hourly, daily, ...
TIMELINE_CREATE="yes"
TIMELINE_CLEANUP="yes"
TIMELINE_MIN_AGE="3600"
TIMELINE_LIMIT_HOURLY="10"
TIMELINE_LIMIT_DAILY="10"
TIMELINE_LIMIT_WEEKLY="0"
TIMELINE_LIMIT_MONTHLY="10"
TIMELINE_LIMIT_QUARTERLY="0"
TIMELINE_LIMIT_YEARLY="10"

EMPTY_PRE_POST_CLEANUP="yes"
EMPTY_PRE_POST_MIN_AGE="3600"
',
    },
  ]
}

export def setup [--verbose] {
  ensure-installed snapper --verbose=$verbose
  ensure-installed btrfs-assistant --verbose=$verbose

  let snapper_config_dir = "/etc/snapper/configs/"

  let s = subvolumes
  for subvol in $s {
    if $verbose {
      print $"Creating or updating snapshot config for ($subvol.name)"
    }

    let $config_file_path = $snapper_config_dir | path join $subvol.name
    if not ($config_file_path | path exists) {
      if $verbose {
        print $"Subvolume ($subvol.name) didn't have a snapper config yet. Creating ..."
      }
      sudo snapper -c $subvol.name create-config $subvol.subvolume_mountpoint
    }

    # TODO this should be moved to a separate utility function to write to
    # system files
    let tmpfile = mktemp --directory | path join $subvol.name
    if $verbose {
      print $"Writing first to temporary file ($tmpfile)"
    }
    echo $subvol.config | save $tmpfile
    sudo cp $tmpfile $config_file_path
  }
}
