#!/bin/bash
# this code will check if there is a new module that dont have a test diractory, in that case it will bring back
# the missing test file that the user will need to add to the repo.

dir1="tests"
dir2="modules"

dir1_dirs=$(find "$dir1" -type d -maxdepth 1 -mindepth 1 -exec basename {} \;)
dir2_dirs=$(find "$dir2" -type d -maxdepth 1 -mindepth 1 -exec basename {} \;)

output=$(echo "${dir2_dirs[@]} ${dir1_dirs[@]}" | tr ' ' '\n' | sort | uniq -u)

echo $output
