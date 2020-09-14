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

if [[ -d "${HERBERT_DIR}" ]]; then
    echo_and_run "git -C ${HERBERT_DIR} fetch -all --tags" &&
    echo_and_run "git -C ${HERBERT_DIR} reset --hard \"${herbert_branch}\""
else
    git_clone_cmd="git clone ${HERBERT_URL} --depth 1"
    git_clone_cmd+=" --branch \"${herbert_branch}\" ${HERBERT_DIR}"
    echo_and_run "${git_clone_cmd}"
fi

echo -e "\nBuilding Herbert revision $(git -C ${HERBERT_DIR} rev-parse HEAD)..."
build_cmd="${HERBERT_DIR}/tools/build_config/build.sh --build"
build_cmd+=" --build_tests OFF ${build_args}"
echo_and_run "${build_cmd}"
