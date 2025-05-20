export def setup_btrfs_swap [] {
  if (swapon --show | lines | length) > 1 {
    print "Swap is already configured"
    return
  }

  sudo btrfs subvolume create /swap
  sudo btrfs filesystem mkswapfile --size 16g --uuid clear /swap/swapfile
  sudo swapon /swap/swapfile
  echo '/swap/swapfile none swap defaults 0 0' | sudo tee -a /etc/fstab
}
