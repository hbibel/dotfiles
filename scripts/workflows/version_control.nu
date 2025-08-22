use std/log

export def --env wt [name?: string] {
  # Main work is split into separate function, since this function modifies the
  # callers environment
  let cd_dir = wt_dir $name
  cd $cd_dir
}

def wt_dir [name?: string] {
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
  git pull

  let name = if $name != null { $name } else {
    let available_branches = (
      # lstrip removes path components from the full name, e.g.
      # refs/remotes/origin/foo -> strip refs, remotes, origin -> leaves foo
      git branch --all --format="%(refname:lstrip=3)" |
      lines |
      uniq |
      each {|branch| if ($branch | str trim | str starts-with "remotes") {
        $branch | str trim | split row --number 3 "/" | get 2
      } else {
        $branch | str trim
      }}
    )
    (
      $available_branches |
      str join "\n" |
      fzf --bind 'enter,return:accept-or-print-query'
    )
  }

  # Note that we should be in 'main' now
  let wt_dir_name = $name | str replace '/' '_' | str replace '#' '_'
  let wt_dir = $env.PWD | path join $"../($wt_dir_name)" | path expand

  if ($wt_dir | path exists) {
    cd $wt_dir
    git pull
  } else {
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

      let upstreams = git remote | lines
      if ( ($upstreams | length) == 0 ) {
        print "No upstream configured. Will not push this branch"
      } else if ( ($upstreams | length) > 1 ) {
        log warning $"Don't know which upstream to push to out of [($upstreams | str join ', ')]"
      } else {
        let upstream = $upstreams | get 0
        git push --set-upstream $upstream $name
      }
    }
  }

  $wt_dir
}
