#!/bin/bash

if [[ -z "$1" ]]; then
    echo "No commit message as a parameter."
    exit 1
fi

git status
git add .
git commit -m "$1"
git push

exit 0

