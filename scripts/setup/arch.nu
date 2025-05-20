use std/log

use arch/bluetooth.nu

use arch/cosmic.nu
use arch/yay.nu
use arch/zsh.nu
use arch/wget.nu
use arch/dropbox.nu
use arch/keepass.nu
use arch/joplin.nu
use arch/swap.nu

bluetooth setup
swap setup_btrfs_swap

cosmic install
yay install

wget install

# zsh install # TODO configure OMZ

dropbox install
keepass install
joplin install
