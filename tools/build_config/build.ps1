param (
  [int]$vs_version = 2017,
  [string]$build_config = 'Release',
  [string]$build_dir = "",
  [string]$build_tests = "On",
  [string]$install_dir = "",
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

function Write-And-Invoke([string]$command) {
  Write-Output "+ $command"
  Invoke-Expression "$command"
}

function Write-Versions() {
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
  $cmake_generator = "$($VS_VERSION_MAP[$vs_version])"
  if ($vs_version -eq '2019') {
    $generator_cmd += "-G ""$cmake_generator"" -A x64"
  }
  else {
    $generator_cmd += "-G ""$cmake_generator Win64"""
  }
  $cmake_cmd = "cmake $HERBERT_ROOT"
  $cmake_cmd += " $generator_cmd"
  $cmake_cmd += " -DCMAKE_BUILD_TYPE=$build_config"
  $cmake_cmd += " -DBUILD_TESTS=$build_tests"
  $cmake_cmd += " -DBUILD_FORTRAN=$build_fortran"
  $cmake_cmd += " $cmake_flags"

  Write-And-Invoke "$cmake_cmd"
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
  try {
    Write-And-Invoke "ctest -C $build_config -T Test"
  }
  finally {
    Pop-Location
  }
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
}

function Invoke-Package() {
  Write-Output "`nRunning package step..."
  Write-And-Invoke "cpack -G ZIP"
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
}


# Resolve/set default parameters
if ($build_dir -eq "") {
  $build_dir = Join-Path -Path $HERBERT_ROOT -ChildPath 'build'
}
if ($install_dir -eq "") {
  $install_dir = Join-Path -Path $HERBERT_ROOT -ChildPath 'install'
}

if ($print_versions -eq $true) {
  Write-Versions
}

if ($build -eq $true) {
  try {
    Write-Output "Creating build directory: $build_dir"
    $mkdir_cmd = "New-Item -Path $build_dir -ItemType Directory -ErrorAction Stop | Out-Null"
    Write-And-Invoke "$mkdir_cmd"
  }
  catch [System.IO.IOException] {
    Write-Warning $_.Exception.Message
    Write-Warning "This may not be a clean build."
  }
  Push-Location -Path $build_dir
  try {
    Invoke-Configure `
      -vs_version $vs_version `
      -build_dir $build_dir `
      -build_config $build_config `
      -build_tests $build_tests `
      -build_fortran $build_fortran `
      -cmake_flags $cmake_flags
  }
  finally {
    Pop-Location
  }

  Invoke-Build -build_dir $build_dir -build_config $build_config
}

if ($test -eq $true) {
  Invoke-Test -build_dir $build_dir -build_config $build_config
}

if ($package -eq $true) {
  Push-Location -Path $build_dir
  try {
    Invoke-Package
  }
  finally {
    Pop-Location
  }
}
