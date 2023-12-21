#!/bin/bash

# Simply check if diff in changelog exists.
git diff --exit-code --quiet origin/master... ./CHANGELOG.md
if [ $? -ne 1 ]; then
  echo "Please add a changelog entry in CHANGELOG.md or add 'skip changelog' label to your PR if this change does not require an entry".
  exit 1
fi