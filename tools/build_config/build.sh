#!/usr/bin/env bash

set -o errexit  # exit early on any error
set -o nounset  # raise error using unset variables

readonly FALSE=0
readonly TRUE=1
readonly CMAKE_GENERATOR="Unix Makefiles"
# The Horace root directory is two levels above this script
readonly HORACE_ROOT="$(realpath "$(dirname "$0")"/../..)"
# The Matlab root directory is one level above Matlab/bin which contains the
# matlab executable. The Matlab on the path will likely be a symlink so we need
# to resolve it with `readlink`
readonly MATLAB_ROOT="$(realpath "$(dirname "$(readlink -f "$(which matlab)")")"/..)"
readonly MAX_CTEST_SUCCESS_OUTPUT_LENGTH=10000 # 10 kilobytes

# shellcheck source=../bash/bash_helpers.sh
. "${HORACE_ROOT}/tools/bash/bash_helpers.sh"

function print_package_versions() {
  cmake --version | head -n 1
  echo "Matlab: ${MATLAB_ROOT}"
  g++ --version | head -n 1
  cppcheck --version | head -n 1
  echo
}

function run_configure() {
  local build_dir=$1
  local build_config=$2
  local build_tests=$3
  local matlab_release=$4
  local cmake_flags="${5-}"  # Default value is empty string

  warning_msg="Warning: Build directory ${build_dir} already exists.\n\
                              This may not be a clean build."
  echo_and_run "mkdir ${build_dir}" || warning "${warning_msg}"

  cmake_cmd="cmake ${HORACE_ROOT}"
  cmake_cmd+=" -G \"${CMAKE_GENERATOR}\""
  cmake_cmd+=" -DMatlab_ROOT_DIR=${MATLAB_ROOT}"
  cmake_cmd+=" -DCMAKE_BUILD_TYPE=${build_config}"
  cmake_cmd+=" -DBUILD_TESTS=${build_tests}"
  cmake_cmd+=" -DMatlab_RELEASE=${matlab_release}"
  cmake_cmd+=" ${cmake_flags}"

  echo -e "\nRunning CMake configure step..."
  run_in_dir "${cmake_cmd}" "${build_dir}"
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
  test_cmd="ctest -T Test --no-compress-output"
  test_cmd+=" --output-on-failure"
  test_cmd+=" --test-output-size-passed ${MAX_CTEST_SUCCESS_OUTPUT_LENGTH}"
  run_in_dir "${test_cmd}" "${build_dir}"
}

function run_analysis() {
  local build_dir=$1
  echo_and_run "cmake --build ${build_dir} -- analyse"
}

function run_package() {
  echo -e "\nRunning package step..."
  echo_and_run "cd ${build_dir}"
  echo_and_run "cpack -G TGZ"
}

function build_docs() {
    # Update release numbers
    echo_and_run "cmake --build ${build_dir} --target docs"

    # Compress for artifact
    tar -czf docs.tar.gz ./documentation/user_docs/build/html/*
}

function push_built_docs() {
    build_id=$(sed -nr '/CPACK_PACKAGE_FILE_NAME/{s/.*"Horace-([^"]+)".*/\1/p};' ./build/CPackConfig.cmake)
    git config --local user.name "PACE CI Build Agent"
    git config --local user.email "pace.builder.stfc@gmail.com"
    git remote set-url --push origin "https://pace-builder:"${api_token## }"@github.com/pace-neutrons/Horace"
    git checkout gh-pages
    git pull
    echo "Bypassing Jekyll on GitHub Pages" > .nojekyll
    git add .nojekyll
    git rm -rf --ignore-unmatch ./unstable
    cp -r ./documentation/user_docs/build/html ./unstable
    git add unstable
    git commit -m "Document build from CI ("$build_id")"
    git push origin gh-pages
}

function print_help() {
  readonly local help_msg="Script to build, run static analysis, test and package Horace.

This script requires Matlab, GCC, CMake>=3.7 and CTest be installed on your
system and available on the path.

This script also requires that Herbert be findable by CMake. CMake will search
in common places for Herbert e.g. in the same directory as Horace.

https://github.com/pace-neutrons/Horace

usage:
  ./build.sh flag1 [flag2 [flag3]...] [option1 argument1 [option2 argument2]...]
flags:
  -b, --build
      Run the Horace build commands.
  -t, --test
      Run all Horace tests.
  -c, --configure
      Run cmake configuration stage
  -a, --analyze
      Run static analysis on Horace code.
  -p, --package
      Pacakge Horace into a .tar.gz file.
  -v, --print_versions
      Print the versions of libraries being used e.g. Matlab.
  -d, --docs
      Build user docs
  --push_docs
      Push docs up to Horace GitHub repo
  -h, --help
      Print help message and exit.
options:
  -X, --build_tests {\"ON\", \"OFF\"}
      Whether to build the Horace C++ tests and enable testing via CTest.
      This must be \"ON\" in order to run tests with this script. [default: ON]
  -C, --build_config {\"Release\", \"Debug\"}
      The build configuration passed to CMake [default: Release]
  -O, --build_dir
      The directory to write build files into. If the directory does not exist
      it will be created. [default: build]
  -F, --cmake_flags
      Flags to pass to the CMake configure step.
  -M, --matlab_release
      The release of Matlab to build and run tests against e.g. R2018b. This
      Matlab release should also be on your path.
example:
  ./build.sh --build --test --build_config Debug
"
  echo -e "${help_msg}"
}

function main() {
  # set default parameter values
  local build=$FALSE
  local test=$FALSE
  local configure=$FALSE
  local analyze=$FALSE
  local package=$FALSE
  local docs=$FALSE
  local push_docs=$FALSE
  local print_versions=$FALSE
  local build_tests="ON"
  local build_config='Release'
  local build_dir="${HORACE_ROOT}/build"
  local matlab_release=""
  local cmake_flags=""

  # parse command line args
  while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        # flags
        -b|--build) build=$TRUE; shift ;;
        -t|--test) test=$TRUE; shift ;;
        -c|--configure) configure=$TRUE; shift;;
        -a|--analyze) analyze=$TRUE; shift ;;
        -p|--package) package=$TRUE; shift ;;
        -d|--docs) docs=$TRUE; shift;;
        --push-docs) push_docs=$TRUE; shift;;
        -v|--print_versions) print_versions=$TRUE; shift ;;
        -h|--help) print_help; exit 0 ;;
        # options
        -X|--build_tests) build_tests="$2"; shift; shift ;;
        -C|--build_config) build_config="$2"; shift; shift ;;
        -O|--build_dir) build_dir="$(realpath $2)"; shift; shift ;;
        -M|--matlab_release) matlab_release="$2"; shift; shift ;;
        -F|--cmake_flags) cmake_flags="$2"; shift; shift ;;
        *) echo "Unrecognised argument '$key'"; exit 1 ;;
    esac
  done

  if ((print_versions)); then
    print_package_versions
  fi

  if ((configure)) || [ ! -e ${build_dir}/CMakeCache.txt ]; then
    run_configure "${build_dir}" "${build_config}" "${build_tests}" "${matlab_release}" "${cmake_flags}"
  fi

  if ((analyze)); then
    run_analysis "${build_dir}"
  fi

  if ((build)); then
    run_build "${build_dir}"
  fi

  if ((test)); then
    run_tests "${build_dir}"
  fi

  if ((package)); then
    run_package
  fi

  if ((docs)); then
    build_docs
  fi

  if ((push_docs)); then
    push_built_docs
  fi
}

main "$@"
