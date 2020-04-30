# Clone and build the given Herbert branch. If no branch is given, default to
# master
# Pass a specific branch using the -branch parameter, any other arguments are
# passed verbatim to the Herbert build script

param(
  [string]$branch = "master",
  [string]$build_args = ""
)

<# Import:
    Write-And-Invoke
    Invoke-In-Dir #>
. $PSScriptRoot/powershell_helpers.ps1

$HERBERT_URL = "https://github.com/pace-neutrons/Herbert.git"
$HERBERT_DIR = "Herbert-download"
$HERBERT_BUILD_DIR = "$HERBERT_DIR/build"
$HERBERT_INSTALL_DIR = "$($(Get-Location).Path)/Herbert"

Write-Output "Building Herbert branch $branch..."
if (Test-Path -Path "$HERBERT_DIR") {
  Write-And-Invoke "git -C $HERBERT_DIR fetch origin"
  Write-And-Invoke "git -C $HERBERT_DIR reset --hard origin/$branch"
} else {
  Write-And-Invoke "git clone $HERBERT_URL --depth 1 --branch $branch $HERBERT_DIR"
}
$build_cmd = "$HERBERT_DIR/tools/build_config/build.ps1 -build"
$build_cmd += " -build_dir $HERBERT_BUILD_DIR"
$build_cmd += " -build_tests OFF $build_args"
Write-And-Invoke "$build_cmd"

# Set Herbert's CMake install directory
$set_install_dir_cmd = "cmake -B$HERBERT_BUILD_DIR -H$HERBERT_DIR"
$set_install_dir_cmd += " -DCMAKE_INSTALL_PREFIX=$HERBERT_INSTALL_DIR"
Write-And-Invoke "$set_install_dir_cmd"

# Run the "install" build target - this copies a package into the install dir
$install_cmd = "cmake --build $HERBERT_BUILD_DIR --target INSTALL"
Write-And-Invoke "$install_cmd"
