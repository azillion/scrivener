workflow "Build and deploy" {
  on = "push"
  resolves = [
    "Trigger Netlify Deploy",
    "Build",
    "Master",
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
  runs = "docker build --build-arg REPOSITORY_ARG=$REPOSITORY --build-arg GITHUB_TOKEN_ARG=$GITHUB_TOKEN --build-arg GITHUB_SHA_ARG=$GITHUB_SHA --build-arg GITHUB_REF_ARG=$GITHUB_REF --build-arg GITHUB_REPOSITORY_ARG=$GITHUB_REPOSITORY -t azillion/scrivener ."
  secrets = ["GITHUB_TOKEN"]
  env = {
    REPOSITORY = "scrivener"
  }
}

action "Trigger Netlify Deploy" {
  uses = "swinton/httpie.action@8ab0a0e926d091e0444fcacd5eb679d2e2d4ab3d"
  needs = ["Build"]
  args = ["POST", "$NETLIFY_DEPLOY_URL"]
  secrets = [
    "NETLIFY_DEPLOY_URL",
  ]
}
