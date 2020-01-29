param (
  [int]$vs_version = 2017,
  [string]$build_config = 'Release',
  [string]$build_dir = "",
  [string]$build_tests = "On",
  [string]$cmake_flags = "",
  [string]$build_fortran = "OFF",

  [switch]$build,
  [switch]$test,
  [switch]$package,
  [switch]$print_versions
)

# Mapping from year to Visual Studio version
$VS_VERSION_MAP = @{
  2015 = 'Visual Studio 14 2015';
  2017 = 'Visual Studio 15 2017';
  2019 = 'Visual Studio 16 2019';
}
# Herbert's root directory is two levels above this script
$HERBERT_ROOT = Resolve-Path (Join-Path -Path $PSScriptRoot -ChildPath '/../..')
$MAX_CTEST_SUCCESS_OUTPUT_LENGTH = 10000 # 10kB

function Write-And-Invoke([string]$command) {
  Write-Output "+ $command"
  Invoke-Expression "$command"
}

function Invoke-In-Dir {
  param([string]$directory, [string]$command)
  Push-Location -Path $directory
  try {
    Write-And-Invoke "$command"
  }
  finally {
    Pop-Location
  }
}

function New-Build-Directory {
  param([string]$build_dir)
  try {
    Write-Output "Creating build directory: $build_dir"
    $mkdir_cmd = "New-Item -Path $build_dir -ItemType Directory -ErrorAction Stop | Out-Null"
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
  if ($vs_version -eq '2019') {
    $generator_cmd += "-G ""$cmake_generator"" -A x64"
  }
  else {
    $generator_cmd += "-G ""$cmake_generator Win64"""
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
    [string]$build_fortran,
    [string]$cmake_flags
  )
  Write-Output "`nRunning CMake configure step..."
  $cmake_cmd = "cmake $HERBERT_ROOT"
  $cmake_cmd += " $(New-CMake-Generator-Command -vs_version $vs_version)"
  $cmake_cmd += " -DCMAKE_BUILD_TYPE=$build_config"
  $cmake_cmd += " -DBUILD_TESTS=$build_tests"
  $cmake_cmd += " -DBUILD_FORTRAN=$build_fortran"
  $cmake_cmd += " $cmake_flags"

  Invoke-In-Dir -directory $build_dir -command $cmake_cmd
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
}

function Invoke-Build {
  param([string]$build_dir, [string]$build_config)
  Write-Output "`nRunning CMake build step..."
  Write-And-Invoke "cmake --build $build_dir --config $build_config"
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
}

function Invoke-Test {
  param([string]$build_dir, [string]$build_config)
  Write-Output "`nRunning test step..."
  Push-Location -Path $build_dir
  $test_cmd = "ctest -C $build_config"
  $test_cmd += " -T Test --no-compress-output"
  $test_cmd += " --output-on-failure"
  $test_cmd += " --test-output-size-passed $MAX_CTEST_SUCCESS_OUTPUT_LENGTH"
  Invoke-In-Dir -directory $build_dir -command $test_cmd
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
}

function Invoke-Package {
  param([string]$build_dir)
  Write-Output "`nRunning package step..."
  Invoke-In-Dir -directory $build_dir -command "cpack -G ZIP"
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
}

# Resolve/set default parameters
if ($build_dir -eq "") {
  $build_dir = Join-Path -Path $HERBERT_ROOT -ChildPath 'build'
}

if ($print_versions -eq $true) {
  Write-Versions
}

if ($build -eq $true) {
  New-Build-Directory -build_dir $build_dir
  Invoke-Configure `
    -vs_version $vs_version `
    -build_dir $build_dir `
    -build_config $build_config `
    -build_tests $build_tests `
    -build_fortran $build_fortran `
    -cmake_flags $cmake_flags
  Invoke-Build -build_dir $build_dir -build_config $build_config
}

if ($test -eq $true) {
  Invoke-Test -build_dir $build_dir -build_config $build_config
}

if ($package -eq $true) {
  Invoke-Package -build_dir $build_dir
}
