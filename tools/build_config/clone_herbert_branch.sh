#!/usr/bin/env bash
# Clone and build the given Herbert branch. If no branch is given, default to
# master

readonly DEFAULT_BRANCH="master"
readonly HERBERT_URL="https://github.com/pace-neutrons/Herbert.git"

readonly bash_helpers="$(realpath "$(dirname "$0")")/bash_helpers.sh"

# shellcheck source=./bash_helpers.sh
. "${bash_helpers}"  # imports echo_and_run

herbert_branch=${1-master}
if [ "${herbert_branch}" = "" ]; then
    herbert_branch="${DEFAULT_BRANCH}"
fi

echo "Cloning and building Herbert branch '${herbert_branch}'..."
if [[ -d "Herbert" ]]; then
    echo_and_run "rm -r Herbert"
fi
echo_and_run "git clone ${HERBERT_URL} --depth 1 --branch ${herbert_branch}" &&
echo_and_run "cd Herbert" &&
echo_and_run "./tools/build_config/build.sh --build"
