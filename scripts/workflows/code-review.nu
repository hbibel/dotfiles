export def main [] {
  git reset --mixed (git merge-base main HEAD)
  nvim -c G .
}
