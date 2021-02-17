<#
.SYNOPSIS
  This script is used to build, test and package Horace on Windows.

.DESCRIPTION
  This script requires Matlab, Visual Studio, CMake>=3.7 and CTest be installed
  on your system and available on the path.

  This script also requires that Herbert be findable by CMake. CMake will search
  in common places for Herbert e.g. in the same directory as Horace.

  Use "Get-Help ./build.ps1 -Detailed" for parameter descriptions.

.EXAMPLE
  ./build.ps1 -build
  # Builds Horace
.EXAMPLE
  ./build.ps1 -test
  # Runs all Horace tests
.EXAMPLE
  ./build.ps1 -package
  # Packages Horace
.EXAMPLE
  ./build.ps1 -build -package -vs_version 2017 -matlab_release R2019a
  # Builds and packages Horace using Visual Studio 2017 and Matlab R2019a

.LINK
  https://github.com/pace-neutrons/Horace
#>
param (
  # Run the Horace build commands.
  [switch][Alias("b")]$build,
  # Run all Horace tests.
  [switch][Alias("t")]$test,
  # Pacakge Horace into a .zip file.
  [switch][Alias("p")]$package,
  # Print the versions of libraries being used e.g. Matlab.
  [switch][Alias("v")]$print_versions,
  # Build docs
  [switch][Alias("d")]$docs,
  # Push docs to github
  [switch]$push_docs,
  # Call Get-Help on this script and exit.
  [switch][Alias("h")]$help,

  # The version of Visual Studio to build with. Other Windows compilers are
  # not supported by this script. {2015, 2017, 2019}
  # [default: use latest installed version or, if rebuilding, the version used
  # in the previous build]
  [int][ValidateSet(2015, 2017, 2019)]
  [Alias("VS")]
  $vs_version = 0,

  # Whether to build the Horace C++ tests and enable testing via CTest.
  # This must be "ON" in order to run tests with this script. {ON, OFF} [default: ON]
  [string][ValidateSet("ON", "OFF")]
  [Alias("X")]
  $build_tests = "ON",

  # The configuration to build with. {Release, Debug} [default: Release]
  [string][ValidateSet("Release", "Debug")]
  [Alias("C")]
  $build_config = 'Release',

  # The directory to write build files into. If the directory does not exist it
  # will be created. [default: build]
  [string]
  [Alias("O")]
  $build_dir = "",

  # Flags to pass to the CMake configure step.
  [string]
  [Alias("F")]
  $cmake_flags = "",

  # The release of Matlab to build and run tests against e.g. R2018b.
  [string][ValidatePattern("R[0-9]{4}[ab]")]
  [Alias("M")]
  $matlab_release = ""
)

if ($args) {
  $error_msg = "Unrecognised argument(s):"
  foreach($arg in $args) {
    $error_msg += "`n    $arg"
  }
  throw "$error_msg"
}

if ($help -or $PSBoundParameters.Values.Count -eq 0) {
  Get-Help "$PSCommandPath"
  exit 0
}

<# Import:
    Write-And-Invoke
    Invoke-In-Dir #>
. $PSScriptRoot/../pwsh/powershell_helpers.ps1

# Mapping from year to Visual Studio version
$VS_VERSION_MAP = @{
  2015 = 'Visual Studio 14 2015';
  2017 = 'Visual Studio 15 2017';
  2019 = 'Visual Studio 16 2019';
}
# Horace's root directory is two levels above this script
$HORACE_ROOT = Resolve-Path (Join-Path -Path "$PSScriptRoot" -ChildPath "/../..")
$MAX_CTEST_SUCCESS_OUTPUT_LENGTH = 10000 # 10kB

function New-Build-Directory {
  param([string]$build_dir)
  try {
    Write-Output "Creating build directory: ""$build_dir"""
    $mkdir_cmd = "New-Item -Path ""$build_dir"" -ItemType Directory -ErrorAction Stop | Out-Null"
    Write-And-Invoke "$mkdir_cmd"
  }
  catch [System.IO.IOException] {
    Write-Warning $_.Exception.Message
    Write-Warning "This may not be a clean build."
  }
}

function New-CMake-Generator-Command {
  param([int]$vs_version)
  $cmake_generator = "$($VS_VERSION_MAP[$vs_version])"
  if ($vs_version -eq 0) {
    $generator_cmd = ""
  } elseif ($vs_version -ge 2019) {
    $generator_cmd = "-G ""$cmake_generator"" -A x64"
  } else {
    $generator_cmd = "-G ""$cmake_generator Win64"""
  }
  return $generator_cmd
}

function Write-Versions {
  Write-Output "$(cmake --version)"
  Write-Output "Matlab: $($(Get-Command matlab.exe).Source)"
  Write-Output "Visual Studio version: $($VS_VERSION_MAP[$vs_version])"
}

function Invoke-Configure {
  param (
    [int]$vs_version,
    [string]$build_dir,
    [string]$build_config,
    [string]$build_tests,
    [string]$matlab_release,
    [string]$cmake_flags
  )
  Write-Output "`nRunning CMake configure step..."
  $cmake_cmd = "cmake ""$HORACE_ROOT"""
  $cmake_cmd += " $(New-CMake-Generator-Command -vs_version $vs_version)"
  $cmake_cmd += " -DBUILD_TESTS=$build_tests"
  $cmake_cmd += " -DMatlab_RELEASE=$matlab_release"
  $cmake_cmd += " $cmake_flags"

  Invoke-In-Dir -directory "$build_dir" -command "$cmake_cmd"
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
}

function Invoke-Build {
  param([string]$build_dir, [string]$build_config)
  Write-Output "`nRunning CMake build step..."
  Write-And-Invoke "cmake --build ""$build_dir"" --config ""$build_config"""
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
}

function Invoke-Test {
  param([string]$build_dir, [string]$build_config)
  Write-Output "`nRunning test step..."
  $test_cmd = "ctest -C $build_config"
  $test_cmd += " -T Test --no-compress-output"
  $test_cmd += " --output-on-failure"
  $test_cmd += " --test-output-size-passed $MAX_CTEST_SUCCESS_OUTPUT_LENGTH"
  Invoke-In-Dir -directory "$build_dir" -command "$test_cmd"
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
}

function Invoke-Package {
  param([string]$build_dir)
  Write-Output "`nRunning package step..."
  Invoke-In-Dir -directory "$build_dir" -command "cpack -G ZIP"
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
}

function Invoke-Docs {
  param([string]$build_dir)
  Write-And-Invoke "cmake --build ""$build_dir"" --target docs"

  Compress-Archive -Path ./documentation/user_docs/build/html/* -DestinationPath "./docs.zip"
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
}

function Invoke-Push {
  git config --local user.name "PACE CI Build Agent"
  git config --local user.email "pace.builder.stfc@gmail.com"
  git remote set-url --push origin "https://pace-builder:$(${env:api_token}.trim())@github.com/pace-neutrons/Horace"
  git checkout gh-pages
  # Keep up to date
  git pull

  Set-Content -Value "Bypassing Jekyll on GitHub Pages" -Path .nojekyll
  git add .nojekyll
  git rm -rf --ignore-unmatch ./unstable
  Copy-Item -Path "./documentation/user_docs/build/html" -Destination "./unstable" -Recurse
  git add unstable

  (Get-Content "./build/CPackConfig.cmake" |
    Where-Object {$_ -match 'CPACK_PACKAGE_FILE_NAME'}) -match '.*"Horace-([^"]+)".*'
  $build_id = $Matches[1]

  git commit -m "Document build from CI (${build_id})"
  git push origin gh-pages
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
}

# Resolve/set default parameters
if ($build_dir -eq "") {
  $build_dir = Join-Path -Path "$HORACE_ROOT" -ChildPath "build"
}

if ($print_versions) {
  Write-Versions
}

if ($build) {
  New-Build-Directory -build_dir "$build_dir"
  Invoke-Configure `
    -vs_version $vs_version `
    -build_dir "$build_dir" `
    -build_config "$build_config" `
    -build_tests "$build_tests" `
    -matlab_release "$matlab_release" `
    -cmake_flags "$cmake_flags"
  Invoke-Build -build_dir "$build_dir" -build_config "$build_config"
}

if ($test) {
  Invoke-Test -build_dir "$build_dir" -build_config "$build_config"
}

if ($package) {
  Invoke-Package -build_dir "$build_dir"
}

if ($docs) {
  Invoke-Docs -build_dir "$build_dir"
}

if ($push_docs) {
  Invoke-Push
}
