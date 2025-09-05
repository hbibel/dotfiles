export def install [spec_version?: string] {
  let install_root = ($env.HOME | path join $"software/python")
  mkdir $install_root
  $env.PYENV_ROOT = $install_root

  if (uname | get kernel-name) == "Darwin" {
    if (which pyenv | is-empty) {
      brew install pyenv
    }
  } else if (uname | get kernel-name) == "Linux" {
    if (uname | get kernel-release | str contains "arch") {
      sudo pacman -S pyenv
    } else {
      error make {msg: $"Not implemented yet for distribution (uname | get kernel-release)" } 
    }
  } else {
    error make {msg: $"Not implemented yet for Kernel (uname | get kernel-name)" } 
  }

  print "Installing Python"

  let pyenv_result = pyenv install --skip-existing ($spec_version | default "3:latest") | complete
  if $pyenv_result.exit_code != 0 {
    error make {msg: $"pyenv failed:\n($pyenv_result.stderr)"}
  }
  if ($pyenv_result.stderr | is-empty) {
    # If the version has already been installed, pyenv will just silently exit
    return
  }

  let $installed_version = (
    $pyenv_result.stderr |
    parse --regex 'Installed Python-(?P<major>\d+)\.(?P<minor>\d+)\.(?P<patch>\d+)' |
    get 0 |
    {
      major: ($in.major | into int) 
      minor: ($in.minor | into int) 
      patch: ($in.patch | into int) 
    }
  )

  let majmin = $"($installed_version.major).($installed_version.minor)"
  let majminptc = $"($installed_version.major).($installed_version.minor).($installed_version.patch)"

  let binary_loc = ($install_root | path join $"versions/($majminptc)/bin/python($majmin)")

  let link_target = ($env.HOME | path join $".local/bin/python($majmin)")
  ln -s $binary_loc $link_target

  ^$binary_loc -m pip install --upgrade pip
}

# # debugpy for debugging in Neovim:
# cd ~/software
# $PY_INSTALL_PATH/bin/python -m venv debugpy
# debugpy/bin/python -m pip install debugpy

export def get_latest_version [partial_version?: string] {
  let version_regex = '(?P<major>\d)+\.(?P<minor>\d+)(\.(?P<patch>\d+))?'

  let version_filter = match $partial_version {
    null => { |v| true }
    _ => {
      let vn = $partial_version | parse --regex $version_regex | get 0
      {
        |v| (($v.major == $vn.major) and
            ($v.minor == $vn.minor) and
            (($vn.patch | is-empty) or ($v.patch == $vn.patch)))
      }
    }
  }

  let ftp_site = ^curl --silent --show-error --fail --location https://www.python.org/ftp/python
  let versions = (
    $ftp_site |
    parse --regex '<a href="(\d(\.\d+)*)\/?">(?P<version>\d.\d+.\d+)'
  )
  let versions = $versions | each { |v| $v.version }

  let compare_versions = {|a,b| do {
    if ($a.major | into int) > ($b.major | into int) {
      return true
    } else if ($a.major | into int) < ($b.major | into int) {
      return false
    }
    if ($a.minor | into int) > ($b.minor | into int) {
      return true
    } else if ($a.minor | into int) < ($b.minor | into int) {
      return false
    }
    if ($a.patch | into int) > ($b.patch | into int) {
      return true
    }
    return false
  }}

  let t = (
    $versions |
    parse --regex $version_regex |
    select major minor patch |
    where $version_filter |
    sort-by --custom $compare_versions |
    first
  )
  $"($t.major).($t.minor).($t.patch)"
}
