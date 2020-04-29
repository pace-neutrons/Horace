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
$HERBERT_DIR = "Herbert"

Write-Output "Building Herbert branch $branch..."
if (Test-Path -Path "$HERBERT_DIR") {
  Invoke-In-Dir -directory "$HERBERT_DIR" -command "git fetch origin"
  Invoke-In-Dir -directory "$HERBERT_DIR" -command "git checkout origin/$branch"
} else {
  Write-And-Invoke "git clone $HERBERT_URL --depth 1 --branch $branch $HERBERT_DIR"
}
$build_cmd = "./tools/build_config/build.ps1 -build -build_tests OFF $build_args"
Invoke-In-Dir -directory "$HERBERT_DIR" -command "$build_cmd"
