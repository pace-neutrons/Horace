#!/usr/bin/env bash

set -o errexit  # exit early on any error
set -o nounset  # raise error using unused variables

readonly FALSE=0
readonly TRUE=1
readonly CMAKE_GENERATOR="Unix Makefiles"
# The Herbert root directory is two levels above this script
readonly HERBERT_ROOT="$(realpath $(dirname "$0")/../..)"
# The Matlab root directory is one level above Matlab/bin which contains the
# matlab executable. The Matlab on the path will likely be a symlink so we need
# to resolve it with `readlink`
readonly MATLAB_ROOT="$(realpath $(dirname $(readlink -f $(which matlab)))/..)"

function echo_and_run {
  echo "+ $1"
  eval "$1"
}

function warning {
  echo -e "\e[33m$1\e[0m"
}

function print_package_versions() {
  echo "$(cmake --version | head -n 1)"
  echo "Matlab: ${MATLAB_ROOT}"
  echo "$(g++ --version | head -n 1)"
  echo
}

function run_configure() {
  local build_dir=$1
  local build_config=$2
  local build_tests=$3

  cmake_cmd="cmake ${HERBERT_ROOT}"
  cmake_cmd+=" -G \"${CMAKE_GENERATOR}\""
  cmake_cmd+=" -DMatlab_ROOT_DIR=${MATLAB_ROOT}"
  cmake_cmd+=" -DCMAKE_BUILD_TYPE=${build_config}"
  cmake_cmd+=" -DBUILD_TESTS=${build_tests}"
  cmake_cmd+=" -BUILD_FORTRAN=${build_fortran}"

  echo -e "\nRunning CMake configure step..."
  echo_and_run "cd ${build_dir}"
  echo_and_run "${cmake_cmd}"
}

function run_build() {
  local build_dir=$1

  echo -e "\nRunning build step..."
  build_cmd="cmake --build ${build_dir}"
  echo_and_run "${build_cmd}"
}

function run_tests() {
  local build_dir=$1

  echo -e "\nRunning test step..."
  echo_and_run "cd ${build_dir}"
  test_cmd="ctest -T Test --no-compress-output --output-on-failure"
  echo_and_run "${test_cmd}"
}

# not yet implemented
function run_package() {
  echo -e "\nRunning package step..."
  echo "Not implemented"
  # echo_and_run "cmake --build install"
}

function main() {
  # set default parameter values
  local build=$FALSE
  local test=$FALSE
  local package=$FALSE
  local print_versions=$FALSE
  local build_tests="ON"
  local build_config='Release'
  local build_dir="${HERBERT_ROOT}/build"
  local build_fortran="ON"
  local install_dir="${HERBERT_ROOT}/install"

  # parse command line args
  while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        # flags
        -b|--build) build=$TRUE; shift ;;
        -t|--test) test=$TRUE; shift ;;
        -p|--package) package=$TRUE; shift ;;
        -v|--print_versions) print_versions=$TRUE; shift ;;
        # options
        -X|--build_tests) build_tests="$2"; shift; shift ;;
        -C|--build_config) build_config="$2"; shift; shift ;;
        -O|--build_dir) build_dir="$(realpath $2)"; shift; shift ;;
        -f|--build_fortran) build_fortran="$2"; shift; shift ;;
        -I|--install_dir) install_dir="$(realpath $2)"; shift; shift ;;
    esac
  done

  if ((${print_versions})); then
    print_package_versions
  fi

  if ((${build})); then
    warning_msg="Warning: Build directory ${build_dir} already exists.\n\
        This may not be a clean build."
    echo_and_run "mkdir ${build_dir}" || warning "${warning_msg}"
    run_configure ${build_dir} ${build_config} ${build_tests}
    run_build ${build_dir}
  fi

  if ((${test})); then
    run_tests ${build_dir}
  fi

  if ((${package})); then
    run_package
  fi
}

main "$@"
