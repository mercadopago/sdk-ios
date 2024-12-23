#!/bin/sh

RED="\e[31m"
GREEN="\e[32m"
MAGENTA="\e[35m"
YELLOW="\e[33m"
ENDCOLOR="\e[0m"

set -e
set -u
set -o pipefail

script_name=$(basename $BASH_SOURCE)
files_to_format=$(mktemp)

function cleanup() {
  rm -f files_to_format
  exit 0
}

trap cleanup 0 1 2 EXIT

if test -d "/opt/homebrew/bin/"; then
    PATH="/opt/homebrew/bin/:${PATH}"
fi
export PATH

#1
git_root_directory=`git rev-parse --show-toplevel`
config="${git_root_directory}/rules.swiftformat"
staged_swift_files=`git diff --diff-filter=d --staged --name-only | grep -e '\(.*\).swift$'`

if [ -z "$staged_swift_files" ]
then
  printf "🟣${MAGENTA} $script_name: No Swift file to format \n.${ENDCOLOR}"
  printf "\n"
  exit 0
fi

printf "%s\n" "${staged_swift_files[@]}" > files_to_format

#2
mint run swiftformat --quiet --config $config --filelist files_to_format --exclude Pods,**/.build,**/Package.swift,vendor/bundle,scripts,fastlane,**/L10n.swift,**/Assets.swift,**/*.generated.swift,**/Generated,xcode-productivity/**/*.swift,**/Carthage/**/*.swift
formatting_result=$?

#3
git add $staged_swift_files

#4
if [ $formatting_result -eq 0 ]; then
    printf "🟢${GREEN} $script_name: The following files have been formatted with SwiftFormat:\n${ENDCOLOR}"
    printf "${MAGENTA}$(cat files_to_format)${ENDCOLOR}\n"
else
    printf "🔴${RED} $script_name: swift_format_pre_commit failed ${ENDCOLOR}"
fi

exit $formatting_result