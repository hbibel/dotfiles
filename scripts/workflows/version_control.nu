use std/log

export def --env wt [name: string] {
  # Main work is split into separate function, since this function modifies the
  # callers environment
  let cd_dir = wt_dir $name
  cd $cd_dir
}

def wt_dir [name: string] {
  let orig_dir = $env.PWD
  while ($env.PWD != $env.HOME and not ($env.PWD | path join "../main/.git" | path exists)) {
    cd ..
  }
  if ($env.PWD == $env.HOME) {
    error make { 
      msg: $"Could not find directory of main branch, is ($orig_dir) a git repository?" 
    }
  }
  cd "../main"
  let wt_dir_name = $name | str replace '/' '_'
  let wt_dir = $env.PWD | path join $"../($wt_dir_name)" | path expand

  git pull

  let exists_on_remote = (
    git branch --remotes |
    lines |
    split column --number 2 '/' remote_name branch_name |
    any { |row| ($row | get branch_name) == $name }
  )
  if $exists_on_remote {
    git worktree add $wt_dir $name
  } else {
    print $"Branch ($name) does not exist on remote, creating it ..."
    git worktree add $wt_dir

    let upstreams = (
      git remote | lines
    )
    if ( ($upstreams | length) == 0 ) {
      print "No upstream configured. Will not push this branch"
    } else if ( ($upstreams | length) > 1 ) {
      log warning $"Don't know which upstream to push to out of [($upstreams | str join ', ')]"
    } else {
      let upstream = $upstreams | get 0
      git push --set-upstream $upstream $name
    }
  }

  $wt_dir
}
