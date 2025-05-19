use std/log

export def install [] {
  if not (which dropboxd | is-empty) {
    log info "already installed: dropbox"
    return
  }

  cd ~
  wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
  mkdir ~/.local/bin
  ln -s ~/.dropbox-dist/dropboxd ~/.local/bin/dropboxd

  wget -O ~/.local/bin/dropbox.py https://www.dropbox.com/download?dl=packages/dropbox.py
  chmod +x ~/.local/bin/dropbox.py

  ~/.local/bin/dropbox.py start
}
