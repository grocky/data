#!/usr/bin/env bash

# Methodology extracted from: https://stackoverflow.com/a/25023044/818073
# Requires: 
#   - httpie
#   - jq

# https://github.com/jeroenjanssens/data-science-at-the-command-line/tree/master/tools

github_domain=https://api.github.com
auth_options="--auth grocky:$(find_password github_grocky_token)"
repo=jeroenjanssens/data-science-at-the-command-line

github_GET() {
  uri=${1}
  http ${auth_options} GET ${github_domain}${uri} Accept:application/vnd.github.v3+json
}

log() {
  if [ "${DISABLE_LOGS}" = "1" ]; then 
    return 
  fi
  printf "%s - %s\n" $(date -Iseconds) "$@"
}

get_latest_commit_hash() {
  github_GET /repos/${repo}/commits | jq -r '.[0].sha'
}

get_directory_hash() {
  commit_hash=${1}
  directory=${2}
  tree_hash=$(github_GET /repos/${repo}/git/commits/${commit_hash} | \
    jq -r '.tree.sha')
  github_GET /repos/${repo}/git/trees/${tree_hash} | \
    jq -r --arg directory "$directory" '.tree[] | select(.path == $directory)
      | .sha'
}

list_directory() {
  hash=${1}
  github_GET /repos/${repo}/git/trees/${hash} \
    | jq '[ .tree[] | select(.type == "blob") | { path, url } ]'
}

log "Getting latest commit"
latest_hash=$(get_latest_commit_hash)

log "Getting tools tree hash"
tools_tree_hash=$(get_directory_hash ${latest_hash} "tools")

log "Listing tools directory"
list_directory ${tools_tree_hash}

