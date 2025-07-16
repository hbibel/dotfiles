def main [project_name: string] {
  npm init --yes
  npm pkg set $"name=($project_name)"

  (npm install --save-dev
    "eslint" 
    "@eslint/js"
    "typescript" 
    "typescript-eslint"
    "prettier"
    "@trivago/prettier-plugin-sort-imports"
  )

  git add flake.nix
}
