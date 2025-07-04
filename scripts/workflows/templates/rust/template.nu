def main [project_name: string] {
  open Cargo.toml | update package.name $project_name | save -f Cargo.toml

  # Fetch latest stable rust version
  let rust_channel = http get https://static.rust-lang.org/dist/channel-rust-stable.toml
  let rust_version = ($rust_channel |
    from toml |
    get pkg.rust.version |
    # The version will look something like "1.88.0 (6b00bc388 2025-06-23)",
    # we parse major and minor version from this
    split words |
    take 2 |
    str join '.'
  )
  print $"Using latest stable rust version ($rust_version)"
  open rust-toolchain.toml | update toolchain.channel $rust_version | save -f rust-toolchain.toml

  # Nix requires files for the nix shell to be tracked by git
  git add .
}
