#!/bin/bash
# this code will check if there is a new module that dont have a test diractory, in that case it will bring back
# the missing test file that the user will need to add to the repo.

dir1="tests"
dir2="modules"
missing_tests_directoies=""
missing_tests_files=""

dir1_dirs=$(find "$dir1" -type d -maxdepth 1 -mindepth 1 -exec basename {} \;)
dir2_dirs=$(find "$dir2" -type d -maxdepth 1 -mindepth 1 -exec basename {} \;)

missing_tests_directoies_array=()
while IFS= read -r line; do
  missing_tests_directoies_array+=("$line")
done < <(echo "${dir2_dirs[@]}" "${dir1_dirs[@]}" | tr ' ' '\n' | sort | uniq -u)

test_directories=()
while IFS= read -r line; do
  test_directories+=("$line")
done < <(echo "${dir1_dirs[@]}" | tr ' ' '\n')

# Check if there is a missing test file
for dir in "${test_directories[@]}"; do
    if [[ $dir2_dirs =~ "$dir" ]] && ! [[ -n $(ls "tests/$dir"/*.tf) ]]; then
        missing_tests_files+="$dir "
    fi
done

# Check if there is a missing test directory for a module
for dir in "${missing_tests_directoies_array[@]}"; do
  if ! [[ $dir1_dirs =~ "$dir" ]] && [[ "$dir" != "locals_variables" ]]; then
    missing_tests_directoies+="$dir  "
  fi
done

if [[ -n $missing_tests_directoies ]] && [[ -n $missing_tests_files ]]; then
    echo "[ERROR] Tests that are missing for modules: $missing_tests_directoies. Tests files that are missing: $missing_tests_files"
elif [[ -n $missing_tests_directoies ]]; then 
    echo "[ERROR] Tests that are missing for modules: $missing_tests_directoies"
elif [[ -n $missing_tests_files ]]; then  
    echo "[ERROR] Tests that are missing template file: $missing_tests_files"
elif [[ -z $missing_tests_directoies ]] && [[ -z $missing_tests_files ]]; then
    echo ""
fi