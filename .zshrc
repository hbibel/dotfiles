[ -f ~/.zshrc.local ] && source ~/.zshrc.local

alias dotfiles='/usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME"'
alias mount_nas="sudo mount --mkdir -t cifs //illmatic/homes/bossman /mnt/illmatic -o username=$ILLMATIC_USERNAME,password=$ILLMATIC_PASSWORD,iocharset=utf8"
