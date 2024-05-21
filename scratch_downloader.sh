#!/bin/bash

user=tiiima
limit=40
offset=0
move="/home/timur/tima/scratch_all/$(date '+%Y%m%d')"
if ! [[ -d "$move" ]]; then
  mkdir "$move"
fi
cd "$move"
sbdl() {
  /home/timur/sbdl/node_modules/.bin/sbdl "$@"
}

projects=()
echo "Getting list of projects for $user" >&2

while true; do
  echo "offset: $offset" >&2
  json=$(curl -s "https://api.scratch.mit.edu/users/$user/projects?limit=$limit&offset=$offset")

  if [[ "$(echo "$json" | jq '. | length')" -eq 0 ]]; then
    break
  fi

  readarray -t arr < <(echo "$json" | jq -r '.[].id')
  projects+=("${arr[@]}")

  offset=$((offset + limit))
done

n_projects=${#projects[@]}
echo "Found $n_projects projects" >&2

counter=0

for project in "${projects[@]}"; do
  counter=$((counter + 1))
  percent=$((counter * 10000 / n_projects))
  percent=$((percent / 100)).$((percent / 10 % 10))$((percent % 10))
  echo "Downloading $project, $counter/$n_projects ($percent%)" >&2
  sbdl "$project"
done

