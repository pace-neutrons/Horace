#!/usr/bin/env bash
# Clone and build the given Herbert branch. If no branch is given, default to
# master

readonly DEFAULT_BRANCH="master"
readonly HERBERT_DIR="Herbert"
readonly HERBERT_URL="https://github.com/pace-neutrons/Herbert.git"

readonly bash_helpers="$(realpath "$(dirname "$0")")/bash_helpers.sh"

# shellcheck source=./bash_helpers.sh
. "${bash_helpers}"  # imports echo_and_run

while [[ $# -gt 0 ]]; do
key="$1"
case $key in
    --branch) herbert_branch="$2"; shift; shift ;;
    --build_args) build_args="$2"; shift; shift ;;
    *) exit 1;
esac
done

if [ "${herbert_branch}" = "" ]; then
    herbert_branch="${DEFAULT_BRANCH}"
fi

echo "Building Herbert branch '${herbert_branch}'..."
if [[ -d "${HERBERT_DIR}" ]]; then
    echo_and_run "cd ${HERBERT_DIR}" &&
    echo_and_run "git fetch origin" &&
    echo_and_run "git checkout origin/${herbert_branch}"
else
    echo_and_run "git clone ${HERBERT_URL} --depth 1 --branch ${herbert_branch} ${HERBERT_DIR}" &&
    echo_and_run "cd ${HERBERT_DIR}"
fi

echo_and_run "./tools/build_config/build.sh --build --build_tests OFF ${build_args}"
