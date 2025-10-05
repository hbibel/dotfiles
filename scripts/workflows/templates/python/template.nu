def main [project_name: string] {
  git add flake.nix

  nix develop --command bash -c "uv init"
  nix develop --command bash -c "uv add isort mypy ruff pytest"

  open pyproject.toml | update project.name $project_name | save -f pyproject.toml

  # Get current stable version
  # Note that we can't use https://www.python.org/ftp/python because this also
  # lists versions that are not stable yet
  let docs_site = http get https://docs.python.org/3/
  let python_version = (
    $docs_site |
    find -r 'Python \d.\d+.\d+ documentation' |
    get 0 |
    parse --regex '(?P<version>\d+\.\d+\.\d+)' |
    get version.0
  )
  open pyproject.toml | update project.requires-python $"==($python_version)" | save -f pyproject.toml

  cat pyproject.toml tool-settings.toml | save --force pyproject.toml
  rm tool-settings.toml
}
