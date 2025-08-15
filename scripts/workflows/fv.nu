export def main [] {
  let result = fzf | complete
  if ($result.exit_code == 130) {
    print "Aborted"
    return
  }

  let selected_file = $result.stdout | str trim
  nvim $selected_file
}
