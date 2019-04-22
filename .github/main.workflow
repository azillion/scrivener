workflow "Build and deploy" {
  on = "push"
  resolves = ["Trigger Netlify Deploy"]
}

action "Build" {
  uses = "actions/docker/cli@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  runs = "docker build -t $GITHUB_REPOSITORY:$GITHUB_SHA ."
}

action "Trigger Netlify Deploy" {
  uses = "swinton/httpie.action@8ab0a0e926d091e0444fcacd5eb679d2e2d4ab3d"
  needs = ["Build"]
  args = ["POST", "$NETLIFY_DEPLOY_URL"]
  secrets = [
    "GITHUB_TOKEN",
    "NETLIFY_DEPLOY_URL",
  ]
}
