#!/bin/bash
#Test Examples
#git-latest.sh https://github.com/jqlang/jq 
#git-latest.sh https://github.com/pypa/pipx
#git-latest.sh https://github.com/docker/compose
#git-latest.sh https://github.com/FreeRDP/FreeRDP
#git-latest.sh https://github.com/docker/compose
#git-latest.sh https://github.com/pypa/pipx
#git-latest.sh https://github.com/nodejs/node

echo "Test Get-Github-Latest See .bashrc"
FILE="$HOME/scripts/github-latest.fn"

if [[ -f $FILE ]]; then
    . "$FILE"
else
    echo "$FILE is missing."
    exit 1
fi

base_name=$(basename $0)

if [[ $# -ne 1 ]] ;then
  echo "USAGE: $base_name https://github.com/<something>"
  exit
fi

get-github-latest $1

#git ls-remote --tags --sort=v:refname $1 | grep -v "rc" | grep -v "{}"  | grep -v "release"  | grep -v "weekly" | tail -n 1 | tr -d '[:space:]' |  rev | cut -d/ -f1 | rev 
#git ls-remote --tags --sort=v:refname $1 | grep -o 'v.*' | sort -r | head -1

exit 0

#!/usr/bin/awk -f
BEGIN {
  if (ARGC != 2) {
    print "git-describe-remote.awk https://github.com/stedolan/jq"
    exit
  }
  FS = "[ /^]+"
  while ("git ls-remote " ARGV[1] "| sort -Vk2" | getline) {
    if (!sha)
      sha = substr($0, 1, 7)
    tag = $3
  }
  while ("curl -s " ARGV[1] "/releases/tag/" tag | getline)
    if ($3 ~ "commits")
      com = $2
  printf com ? "%s-%s-g%s\n" : "%s\n", tag, com, sha
}

