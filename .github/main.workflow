workflow "Build and deploy" {
  on = "push"
  resolves = [
    "Trigger Netlify Deploy",
    "Master",
    "Run",
  ]
}

# Filter for master branch
action "Master" {
  uses = "actions/bin/filter@3c0b4f0e63ea54ea5df2914b4fabf383368cd0da"
  args = "branch master"
}

action "Build" {
  uses = "actions/docker/cli@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  needs = ["Master"]
  runs = "docker build -t azillion/scrivener ."
  secrets = ["GITHUB_TOKEN"]
}

action "Run" {
  uses = "actions/docker/cli@8cdf801b322af5f369e00d85e9cf3a7122f49108"
  needs = ["Build"]
  runs = "docker run --rm --env-file ./env.list azillion/scrivener"
  secrets = ["GITHUB_TOKEN"]
}

action "Trigger Netlify Deploy" {
  uses = "swinton/httpie.action@8ab0a0e926d091e0444fcacd5eb679d2e2d4ab3d"
  needs = ["Run"]
  args = ["POST", "$NETLIFY_DEPLOY_URL"]
  secrets = [
    "NETLIFY_DEPLOY_URL",
  ]
}
