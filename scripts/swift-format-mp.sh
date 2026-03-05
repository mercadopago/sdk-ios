#!/bin/sh

BLUE="\e[34m"      
WHITE="\e[37m"     
GRAY="\e[90m"      
CORAL="\e[38;5;209m" 
GREEN="\e[38;5;71m"  
RED="\e[31m"      
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
  printf "ℹ️ ${BLUE}$script_name:${ENDCOLOR} ${GRAY}No Swift file to format${ENDCOLOR}\n"
  printf "\n"
  exit 0
fi

printf "%s\n" "${staged_swift_files[@]}" > files_to_format

#2
swiftformat . --config .swiftformat.yml
formatting_result=$?

#3
git add $staged_swift_files

#4
if [ $formatting_result -eq 0 ]; then
    printf "✅ ${BLUE}$script_name:${ENDCOLOR} ${WHITE}The following files have been formatted:${ENDCOLOR}\n"
    printf "${GRAY}$(cat files_to_format)${ENDCOLOR}\n"
else
    printf "❌ ${RED}$script_name: swift_format_pre_commit failed${ENDCOLOR}\n"
fi

exit $formatting_result