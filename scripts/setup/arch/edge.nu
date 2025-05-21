use std/log

export def install [] {
  if not (which microsoft-edge-stable | is-empty) {
    log info "already installed: microsoft-edge-stable-bin"
    return
  }

  yay -S --noconfirm --answerclean=None --answerdiff=None microsoft-edge-stable-bin
}


