use std/log

use arch/bluetooth.nu

use arch/cosmic.nu
use arch/yay.nu
use arch/zsh.nu
use arch/wget.nu
use arch/dropbox.nu
use arch/keepass.nu
use arch/joplin.nu
use arch/edge.nu
use arch/swap.nu
use arch/neovim.nu
use arch/wezterm.nu
use arch/goose.nu
use arch/sof.nu

bluetooth setup
swap setup_btrfs_swap
sof install

cosmic install
yay install

wget install

# zsh install # TODO configure OMZ

wezterm install
neovim install
dropbox install
keepass install
joplin install
edge install
goose install
