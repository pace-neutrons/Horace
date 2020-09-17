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
$HERBERT_DIR = "$($(Get-Location).Path)/Herbert"

if (Test-Path -Path "$HERBERT_DIR") {
  Invoke-In-Dir -directory $HERBERT_DIR -command "git fetch --all --tags"
  Invoke-In-Dir -directory $HERBERT_DIR -command "git reset --hard ""$branch"""
} else {
  Write-And-Invoke "git clone $HERBERT_URL --depth 1 --branch ""$branch"" $HERBERT_DIR"
}

Invoke-In-Dir `
    -directory $HERBERT_DIR `
    -command "Write-Output ""``nBuilding Herbert revision `$(git rev-parse HEAD)...""" `

$build_cmd = "$HERBERT_DIR/tools/build_config/build.ps1 -build"
$build_cmd += " -build_tests OFF"
$build_cmd += " $build_args"
Write-And-Invoke "$build_cmd"
