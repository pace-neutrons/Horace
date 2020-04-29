# Clone and build the given Herbert branch. If no branch is given, default to
# master
# Pass a specific branch using the -branch parameter, any other arguments are
# passed verbatim to the Herbert build script

param(
  [string][Alias("B")]$branch = "master",
  [string]$build_args = ""
)

. $PSScriptRoot/powershell_helpers.ps1 <# Imports:
  Write-And-Invoke
  Invoke-In-Dir
#>

$HERBERT_URL = "https://github.com/pace-neutrons/Herbert.git"

Write-Output "Building Herbert branch $branch..."
if (Test-Path -Path "./Herbert") {
  Invoke-In-Dir -directory "Herbert" -command "git fetch origin"
  Invoke-In-Dir -directory "Herbert" -command "git checkout origin/$branch"
} else {
  Write-And-Invoke "git clone $HERBERT_URL --depth 1 --branch $branch"
}
$build_cmd = "./tools/build_config/build.ps1 -build -build_tests OFF $build_args"
Invoke-In-Dir -directory "Herbert" -command "$build_cmd"
