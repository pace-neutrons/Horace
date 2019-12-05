#!/usr/bin/env bash

function echo_and_run {
    echo "cmd: $1"
    eval "$1"
}

this_dir=$(dirname "$0")
horace_src="$this_dir/../.."
build_dir="$horace_src/DLL"

echo_and_run "cmake --version"
echo_and_run "cd $build_dir"

echo -e "\nRunning CMake configure step:"
matlab_root="$(dirname $(readlink -f $(which matlab)))/.."
cmake_conf_cmd="cmake .. -G \"Unix Makefiles\" -DBUILD_TESTS=ON -DMatlab_ROOT_DIR=$matlab_root"
echo_and_run "$cmake_conf_cmd"

echo -e "\nRunning build step:"
build_cmd="cmake --build ."
echo_and_run "$build_cmd"

echo -e "\nRunning test step: "
test_cmd="ctest"
echo_and_run "$test_cmd"
