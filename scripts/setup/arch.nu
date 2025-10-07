use arch/audio.nu
use arch/bluetooth.nu

use arch/cosmic.nu
use arch/nfs.nu
use arch/ntp.nu
use arch/printer.nu
use arch/swap.nu

export def setup [--verbose] {
  swap setup-btrfs-swap

  print "Checking for missing Arch-specific software ..."
  cosmic install --verbose=$verbose
  nfs install --verbose=$verbose
  samba install --verbose=$verbose

  print "Checking drivers and services ..."
  audio setup --verbose=$verbose
  bluetooth setup --verbose=$verbose
  ntp setup --verbose=$verbose
  # NOTE: This script contains interactive prompts
  printer setup --verbose=$verbose
}
