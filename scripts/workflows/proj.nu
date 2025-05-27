export def --env create [name: string] {
  let project_dir = do {
    let projects_dir = $env.HOME | path join "projects"

    if ($name | str trim) == "" {
      print "Please provide a name"
      exit 1
    }

    let project_dir = $projects_dir | path join $name
    if ($project_dir | path exists) {
      print $"directory $($project_dir) already exists"
      exit 1
    }

    print $"\n=> creating directory $($project_dir)\n"
    let project_dir = $project_dir | path join "main"
    mkdir $project_dir
    cd $project_dir
    print "\n=> initializing git repo\n"
    git init

    $project_dir
  }

  cd $project_dir
}
