use std/log

export def update [] {
  let workdir = ($env.HOME | path join "tmp/nvim-install")
  rm -rf $workdir
  mkdir $workdir
  cd $workdir

  let version = select-version
  let archive_name = $"neovim-($version | get name).tar.gz"

  download-archive ($version | get download_url) $archive_name ($version | get digest)

  if (uname | get kernel-name) == "Darwin" {
    xattr -c $archive_name
  }

  let target_dir = ($env.HOME | path join "software/neovim" | path expand)
  unpack-and-move $archive_name $target_dir
  create-bin-link $target_dir

  cd $env.HOME
  rm -rf $workdir
}

def select-version [] {
  let os_tag = match (uname | get kernel-name) {
    "Darwin" => "macos",
    "Linux" => "linux",
    _ => { error make {msg: $"Not implemented yet for Kernel (uname | get kernel-name)" } }
  }
  let arch_tag = match (uname | get machine) {
    "arm64" => "arm64",
    "x86_64" => "x86_64",
    _ => { error make {msg: $"Not implemented yet for processor architecture (uname | get machine)"} }
  }

  # https://docs.github.com/en/rest/releases/releases?apiVersion=2022-11-28#list-releases
  let releases = (
    curl
      --location
      -H "Accept: application/vnd.github+json"
      -H "X-GitHub-Api-Version: 2022-11-28"
      https://api.github.com/repos/neovim/neovim/releases
  ) | from json

  let fzf_result = (
    $releases |
    each {|r| $r | get tag_name } |
    str join "\n" |
    fzf |
    complete
  )
  if ($fzf_result | get exit_code) == 1 {
    return null
  }

  let version = $fzf_result | get stdout | str trim
  log info $"Selected version ($version)"

  let asset = (
    $releases |
    where {|r| ($r | get tag_name) == $version} |
    first |
    get assets |
    where {|a| (
      (($a | get name) | str contains $os_tag) and
      (($a | get name) | str contains $arch_tag) and
      (($a | get name) | str contains "tar.gz")
    )} |
    first
  )

  let digest = $asset | get digest | str replace -r "^sha256:" ""
  return {
    name: $version,
    download_url: ($asset | get browser_download_url),
    digest: $digest,
  }
}

def download-archive [url: string, file_name: string, digest: string] {
  $"($digest)  ($file_name)" | save $"($file_name).sha256"
  # Not using the built-in http command, since this doesn't work with ZScaler
  (
    curl
    --location
    --output $file_name
    $url
  )
  sha256sum --check --strict $"($file_name).sha256"
}

def unpack-and-move [archive_name: string, $target_dir: string] {
  if ($target_dir | path exists) {
    mv $target_dir $"($target_dir).bak"
  }
  mkdir $target_dir

  print $"target_dir: ($target_dir)"

  mkdir "out"
  tar xzf $archive_name --directory "out"
  let neovim_dir = ls "out" | get 0 | get name

  ls $neovim_dir | each {|d| mv $d.name $target_dir}

  rm -rf $"($target_dir).bak"
}

def create-bin-link [target_dir: string] {
  mkdir ($env.HOME | path join "bin")
  rm -f ($env.HOME | path join "bin/nvim")
  ln -s ($target_dir | path join "bin/nvim") ($env.HOME | path join "bin/nvim")
}
