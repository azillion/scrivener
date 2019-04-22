workflow "Build" {
  on = "push"
  resolves = ["HTTP client"]
}

action "Docker Builder" {
  uses = "actions/docker/cli@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  runs = "build -t azillion/scrivener ."
}

action "HTTP client" {
  uses = "swinton/httpie.action@8ab0a0e926d091e0444fcacd5eb679d2e2d4ab3d"
  needs = ["Docker Builder"]
  args = ["POST", "$NETLIFY_DEPLOY_URL"]
  secrets = [
    "GITHUB_TOKEN",
    "NETLIFY_DEPLOY_URL",
  ]
}
