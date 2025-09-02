# Base: https://gist.github.com/danielmacuare/9b916540158040701aebaaf994bf88e7
# Added sqlite3, libzm, libbz2-dev, liblzma-dev
# Also add tk-dev if you need the tkinter API

const version_regex = '(?P<major>\d)+\.(?P<minor>\d+)(\.(?P<patch>\d+))?'

export def install [spec_version?: string] {
  let work_dir = ($env.HOME | path join "tmp/python_install")
  mkdir $work_dir
  cd $work_dir

  let spec_version = if $spec_version == null {
    get_latest_version
  } else {
    get_latest_version $spec_version
  }

  print $"installing Python ($spec_version)"

  (
    curl
    --fail
    --location
    --remote-name
    $"https://www.python.org/ftp/python/($spec_version)/Python-($spec_version).tgz"
  )
  tar -xzf $"Python-($spec_version).tgz"
  cd $"Python-($spec_version)"

  let install_dir = ($env.HOME | path join $"software/python/($spec_version)")
  mkdir $install_dir

  if (uname | get kernel-name) == "Darwin" {
    brew install pkg-config openssl@3.0 xz gdbm tcl-tk
    let gdbm_prefix = brew --prefix gdbm
    let openssl_prefix = brew --prefix openssl@3.0
    with-env {
      GDBM_CFLAGS: $"-I$($gdbm_prefix)/include"
      GDBM_LIBS: $"-L$($gdbm_prefix)/lib -lgdbm"
    } { 
      (
        ./configure
        --prefix $install_dir
        --enable-optimizations
        --with-pydebug
        --with-openssl=$"$($openssl_prefix)"
      )
    }
    make -j (sysctl -n hw.physicalcpu)
    make install
  } else if (uname | get kernel-name) == "Linux" {
    if (uname | get kernel-release | str contains "arch") {
      (
        sudo pacman -S --noconfirm --needed
        openssl
        zlib
        bzip2
        xz
        sqlite
        mpdecimal
        libffi
        tk
        readline
        ncurses
      )
    } else if not (which apt | is-empty) {
      # Check kernel-release for Ubuntu and update condition
      (
        sudo apt install -y
        build-essential
        zlib1g-dev
        libncurses5-dev
        libgdbm-dev
        libnss3-dev
        libssl-dev
        libreadline-dev
        libffi-dev
        libsqlite3-dev
        libncursesw5-dev
        libc6-dev
        libbz2-dev
        libgdbm-compat-dev
        pkg-config
      )
    } else {
      error make {msg: $"Not implemented yet for distribution (uname | get kernel-release)" } 
    }

    (
      ./configure
      --prefix $install_dir
      --enable-optimizations
      --without-tkinter # if you need the tkinter API, remove this line
    )
    # Don't get confused by the message
    # "The necessary bits to build these optional modules were not found"
    make -j (nproc)
    make install
  } else {
    error make {msg: $"Not implemented yet for Kernel (uname | get kernel-name)" } 
  }

  if ((uname | get kernel-name) == "Darwin") or ((uname | get kernel-name) == "Linux") {
    let python_executable = $install_dir | path join "bin/python3"

    ^$python_executable -m pip install --upgrade pip

    # link to python3.x
    let major_minor = $spec_version | split row '.' | $"($in.0).($in.1)"
    let link_target = ($env.HOME | path join $".local/bin/python($major_minor)")
    rm -f $link_target
    ln -s ($install_dir | path join $"bin/python3") $link_target

    # link to python3.x.y
    let link_target = ($env.HOME | path join $".local/bin/python($spec_version)")
    ln -s ($install_dir | path join $"bin/python3") $link_target
  } else {
    error make {msg: $"Not implemented yet for Kernel (uname | get kernel-name)" } 
  }

  rm -rf $work_dir
}

# # debugpy for debugging in Neovim:
# cd ~/software
# $PY_INSTALL_PATH/bin/python -m venv debugpy
# debugpy/bin/python -m pip install debugpy

export def get_latest_version [partial_version?: string] {
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
