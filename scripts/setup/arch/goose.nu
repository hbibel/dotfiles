use std/log

export def install [] {
  if not (which goose | is-empty) {
    log info "already installed: goose"
    return
  }

  curl -fsSL https://github.com/block/goose/releases/download/stable/download_cli.sh | CONFIGURE=false bash
}

