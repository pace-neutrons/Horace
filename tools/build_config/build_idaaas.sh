#!/usr/bin/bash

set -o errexit  # exit early on any error
set -o nounset  # raise error using unused variables

readonly FALSE=0
readonly TRUE=1
readonly CMAKE_GENERATOR="Unix Makefiles"
# The Herbert root directory is two levels above this script
readonly HERBERT_ROOT="$(realpath "$(dirname "$0")"/../..)"
# The Matlab root directory is one level above Matlab/bin which contains the
# matlab executable. The Matlab on the path will likely be a symlink so we need
# to resolve it with `readlink`
readonly MATLAB_ROOT="$(realpath "$(dirname "$(readlink -f "$(command -v matlab)")")"/..)"
readonly MAX_CTEST_SUCCESS_OUTPUT_LENGTH="10000" # 10kB

. "${HERBERT_ROOT}/tools/bash/bash_helpers.sh"

function print_package_versions() {
  cmake3 --version | head -n 1
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

  cmake_cmd="cmake3 ${HERBERT_ROOT}"
  cmake_cmd+=" -G \"${CMAKE_GENERATOR}\""
  cmake_cmd+=" -DMatlab_ROOT_DIR=${MATLAB_ROOT}"
  cmake_cmd+=" -DCMAKE_BUILD_TYPE=${build_config}"
  cmake_cmd+=" -DBUILD_TESTING=${build_tests}"
  cmake_cmd+=" -DMatlab_RELEASE=${matlab_release}"
  cmake_cmd+=" ${cmake_flags}"

  echo -e "\nRunning CMake configure step..."
  run_in_dir "${cmake_cmd}" "${build_dir}"
}

function run_build() {
  local build_dir=$1

  echo -e "\nRunning build step..."
  build_cmd="cmake3 --build ${build_dir}"
  echo_and_run "${build_cmd}"
}

function run_tests() {
  local build_dir=$1

  echo -e "\nRunning test step..."
  echo_and_run "cd ${build_dir}"
  test_cmd="ctest -T Test --no-compress-output"
  test_cmd+=" --output-on-failure"
  test_cmd+=" --test-output-size-passed ${MAX_CTEST_SUCCESS_OUTPUT_LENGTH}"
  echo_and_run "${test_cmd}"
}

function run_analysis() {
  local build_dir=$1

  echo_and_run "cmake3 --build ${build_dir} -- analyse"
}

function run_package() {
  echo -e "\nRunning package step..."

  run_in_dir "cpack -G TGZ" "${build_dir}"
}

function print_help() {
  readonly local help_msg="Script to build, run static analysis, test and package Herbert.

This script requires Matlab, GCC, CMake>=3.7 and CTest be installed on your
system and available on the path.

https://github.com/pace-neutrons/Herbert

usage:
  ./build.sh flag1 [flag2 [flag3]...] [option1 argument1 [option2 argument2]...]
flags:
  -b, --build
      Run the Herbert build commands.
  -t, --test
      Run all Herbert tests.
  -c, --configure
      Run cmake configuration stage
  -a, --analyze
      Run static analysis on Herbert code.
  -p, --package
      Pacakge Herbert into a .tar.gz file.
  -v, --print_versions
      Print the versions of libraries being used e.g. Matlab.
  -h, --help
      Print help message and exit
options:
  -X, --build_tests {\"ON\", \"OFF\"}
      Whether to build the Herbert C++ tests and enable testing via CTest.
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
  echo "in main"
  # set default parameter values
  local build=$FALSE
  local test=$FALSE
  local configure=$FALSE
  local analyze=$FALSE
  local package=$FALSE
  local print_versions=$FALSE
  local build_tests="ON"
  local build_config='Release'
  local build_dir="${HERBERT_ROOT}/build"
  local cmake_flags=""
  local matlab_release=""

  
  # If no input arguments, print the help and exit
  if [ $# -eq 0 ]; then
    print_help
    exit 0
  fi

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
        -v|--print_versions) print_versions=$TRUE; shift ;;
        -h|--help) print_help; exit 0 ;;
        # options
        -X|--build_tests) build_tests="$2"; shift; shift ;;
        -C|--build_config) build_config="$2"; shift; shift ;;
        -O|--build_dir) build_dir="$(realpath "$2")"; shift; shift ;;
        -F|--cmake_flags) cmake_flags="$2"; shift; shift ;;
        -M|--matlab_release) matlab_release="$2"; shift; shift ;;
        *) echo "Unrecognised argument '$key'. Use -h for usage."; exit 1 ;;
    esac
  done

  if ((print_versions)); then
    print_package_versions
  fi

  if ((configure)) || [ ! -e ${build_dir}/CMakeCache.txt ]; then
    warning_msg="Warning: Build directory ${build_dir} already exists.\n\
        This may not be a clean build."
    echo_and_run "mkdir ${build_dir}" || warning "${warning_msg}"
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
}

main "$@"
