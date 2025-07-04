export def --env create [
  name: string
  --template (-t): string
] {
  let templates_dir = $env.HOME | path join "scripts/workflows/templates" 
  if not ($templates_dir | path exists) {
    error make { msg: $"misconfiguration in proj.nu: ($templates_dir) does not exist" }
  }

  let project_dir = do {
    let projects_dir = $env.HOME | path join "projects"

    if ($name | str trim) == "" {
      print "Please provide a name"
      exit 1
    }

    let project_dir = $projects_dir | path join $name
    if ($project_dir | path exists) {
      error make { msg: $"directory ($project_dir) already exists" }
    }

    print $"\n=> creating directory ($project_dir)\n"
    let project_dir = $project_dir | path join "main"
    mkdir $project_dir
    cd $project_dir
    print "\n=> initializing git repo\n"
    git init

    $project_dir
  }

  cd $project_dir

  if $template != null {
    let template_dir = $templates_dir | path join $template
    if not ($templates_dir | path join $template | path exists) {
      print $"Template '($template)' does not exist. Available templates:"
      let avail_templates = (
        $templates_dir |
        path expand |
        ls $in |
        get $name |
        path split |
        each { last }
      )
      $avail_templates | each { print }
    }

    print $"Copying from ($template_dir) to ($project_dir)"

    ls $template_dir | get name | each {|f| cp -r $f $project_dir}
    nu template.nu $name

    rm template.nu
  }
}
