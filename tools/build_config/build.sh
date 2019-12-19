#!/usr/bin/env bash

set -o errexit  # exit early on any error
set -o nounset  # raise error using unused variables

FALSE=0
TRUE=1
CMAKE_GENERATOR="Unix Makefiles"
HORACE_ROOT="$(realpath $(dirname "$0")/../..)"
MATLAB_ROOT="$(realpath $(dirname $(readlink -f $(which matlab)))/..)"

# set default parameter values
build=$FALSE
test=$FALSE
package=$FALSE
build_tests="ON"
build_config='Release'
build_dir="${HORACE_ROOT}/build"
install_dir="${HORACE_ROOT}/install"


function echo_and_run {
    echo "+ $1"
    eval "$1"
}

function warning {
    echo -e "\e[33m$1\e[0m"
}

function run_build() {
    echo_and_run "cd ${build_dir}"

    cmake_cmd="cmake ${HORACE_ROOT}"
    cmake_cmd+=" -G \"${CMAKE_GENERATOR}\""
    cmake_cmd+=" -DMatlab_ROOT_DIR=${MATLAB_ROOT}"
    cmake_cmd+=" -DCMAKE_BUILD_TYPE=${build_config}"
    if [ "${build_tests}" == "OFF" ]; then
        cmake_cmd+=" -DBUILD_TESTS=OFF"
    else
        cmake_cmd+=" -DBUILD_TESTS=ON"
    fi

    echo -e "\nRunning CMake configure step..."
    echo_and_run "${cmake_cmd}"

    echo -e "\nRunning build step..."
    build_cmd="cmake --build ${build_dir}"
    echo_and_run "${build_cmd}"
}

function run_tests() {
    echo -e "\nRunning test step..."
    test_cmd="ctest -T Test --no-compress-output"
    echo_and_run "${test_cmd}"
}

# not yet implemented
function run_package() {
    echo -e "\nRunning package step..."
    echo "Not implemented"
    # echo_and_run "cmake --build install"
}

# parse command line args
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        # flags
        -b|--build) build=$TRUE; shift ;;
        -t|--test) test=$TRUE; shift ;;
        -p|--package) package=$TRUE; shift ;;
        # options
        -X|--build_tests) build_tests="$2"; shift; shift ;;
        -C|--build_config) build_config="$2"; shift; shift ;;
        -O|--build_dir) build_dir="$(realpath $2)"; shift; shift ;;
        -I|--install_dir) install_dir="$(realpath $2)"; shift; shift ;;
    esac
done

# print versions
echo "$(cmake --version | head -n 1)"
echo "Matlab: ${MATLAB_ROOT}"
echo "$(g++ --version | head -n 1)"
echo

if ((${build})); then
    warning_msg="Warning: Build directory ${build_dir} already exists.\n\
         This may not be a clean build."
    echo_and_run "mkdir ${build_dir}" || warning "${warning_msg}"
    run_build
fi

if ((${test})); then
    echo_and_run "cd ${build_dir}"
    run_tests
fi

if ((${package})); then
    run_package
fi
