#!/usr/bin/env bash
# Clone and build the given Herbert branch. If no branch is given, default to
# master

readonly DEFAULT_BRANCH="master"
readonly HERBERT_URL="https://github.com/pace-neutrons/Herbert.git"
readonly HERBERT_DIR="$(pwd)/Herbert-download"
readonly HERBERT_BUILD_DIR="${HERBERT_DIR}/build"
readonly HERBERT_INSTALL_DIR="$(pwd)/Herbert"

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
    echo_and_run "git -C ${HERBERT_DIR} fetch origin" &&
    echo_and_run "git -C ${HERBERT_DIR} reset --hard origin/${herbert_branch}"
else
    echo_and_run "git clone ${HERBERT_URL} --depth 1 --branch ${herbert_branch} ${HERBERT_DIR}"
fi

# Run Herbert build
build_cmd="${HERBERT_DIR}/tools/build_config/build.sh --build"
build_cmd+=" --build_tests OFF ${build_args}"
echo_and_run "${build_cmd}"

# Set Herbert's CMake install directory
set_install_dir="cmake -B${HERBERT_BUILD_DIR} -H${HERBERT_DIR}"
set_install_dir+=" -DCMAKE_INSTALL_PREFIX=${HERBERT_INSTALL_DIR}"
echo_and_run "${set_install_dir}"

# Run the install build target - this creates Herbert package in install dir
install_cmd="cmake --build ${HERBERT_BUILD_DIR} --target install"
echo_and_run "${install_cmd}"
