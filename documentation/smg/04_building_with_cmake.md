# Building with CMake

## Build dependencies

To build Herbert/Horace the following will need to be installed:

- [Matlab](https://www.mathworks.com/products/matlab.html) >= 2018b
  - on Linux the desired Matlab version must be on the path when running the
  script
  - on Windows, by default, the latest version is found via the registry
  - STFC staff should see the
    [development environment guide](./02_development_environment.md#getting-matlab)
    for how to obtain Matlab.
- [CMake](https://cmake.org/download/) >= 3.15
  - must be on the path for both Windows and Linux
- System compiler:
  - Linux: [GCC](https://gcc.gnu.org/) >= 6.3.0
  - Windows:
    [Visual Studio build tools](https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2019)
    \>= 2017
- [Herbert](https://github.com/pace-neutrons/Herbert)
  - CMake will search for a local copy of Herbert in the same directory as
    Horace is in.
  - It will also search using the environment variable `HERBERT_ROOT`,
    so this can be set to point to a copy of Herbert.
  - For the logic that dictates where Herbert is searched for,
    see [FindHerbert.cmake](../../cmake/FindHerbert.cmake).

## Using build scripts

Horace and Herbert contain PowerShell and Bash scripts named `build.[ps1|sh]`.
These scripts provide an easy way to build Herbert/Horace on Windows or Linux.

Building with just the `--build` flag will build with default options.

From Herbert/Horace's root directory:

PowerShell:

```powershell
>> ./tools/build_config/build.ps1 -build
```

Bash:

```bash
>> ./tools/build_config/build.sh --build
```

_(Note that Bash uses two dashes (`--`) whilst PowerShell uses one.)_

Generally, the default build options will be sufficient,
but there are several configurable parameters.
Both scripts have a `help` flag which display the available actions:

PowerShell:

```powershell
>> ./tools/build_config/build.ps1 -help
```

Bash:

```bash
>> ./tools/build_config/build.sh --help
```

## Using CMake directly

CMake provides a way to generate build files across multiple platforms. It also
ships with a script to aid in compiling Matlab mex libraries.

The following process is roughly what the build scripts described above
automate.

1. After cloning the Horace repository, open the CMake GUI and select the root
of the repository as the source.

2. Select `<Horace Root>/build/` as the binary directory.
Create this directory if it does not exist.

3. Click configure.
When the dialogue appears select your desired generator.
You should pick a compiler that is compatible with your Matlab version,
see the [version compatibility matrix](./09_version_compatibility.md)
(whilst the version compatibility matrix is a good guide,
the mex libraries will likely work if built using newer compiler versions).

4. Make sure to also select your platform/architecture,
this should also match your Matlab version:
if you installed a 64-bit version of Matlab choose x64 as the platform.

    ![alt text](./images/04_cmake_configure_options.png
                "Windows CMake configure options")

    Click finish in the dialogue.
    CMake will find the Matlab compiler and various libraries.

5. Now click generate.
This will generate the projects/Makefiles required to compile the C++ code.

6. To build the generated targets:
    - on Windows, open the `<Horace Root>/build/Horace.sln` file in Visual
      Studio and build the targets.
    - on Linux, from the terminal, `cd` into the build directory and run `make`.

    The built mex files will be written into `horace_core/DLL`.

To perform steps 2-6 using the command line you can use the following commands
(on linux use `-G "Unix Makefiles"`):

`>> cmake -S <Horace Root> -B <Horace Root>/build -G "Visual Studio 15 2017 Win64"`

`>> cmake --build <Horace Root>/build --config Release`

### Troubleshooting

#### Invalid MEX-file

If, when running mex files built using one of the above processes,
you get an error like `Invalid MEX-file: Gateway function is missing`,
this means the mex library is not exporting the correct symbols.

On Windows the mex library (a DLL) should export `mexFunction` and only that.

On Linux, Matlab provides a `.map` file that dictates what symbols to export
from the shared library.
If Matlab was installed in the standard directory on a 64-bit system,
the path to this file will be
`/usr/local/MATLAB/R2018b/extern/lib/glnxa64/mexFunction.map`.

CMake's `matlab_add_mex` function should take care of exporting the symbols,
however there were issues with older versions of CMake on Windows.
This issue should be fixed by
[5638006d67](https://github.com/pace-neutrons/Herbert/commit/5638006d67d538d8b45003d15d957a4369be81e2#diff-34c4edd4cab03f6c20f2e8c75eb90c6b)
, however if you see this error, updating CMake could help.

#### PowerShell execution policy error

If, when running the PowerShell build script,
an error such as the following is thrown:

```txt
File ...\tools\build_config\build.ps1 cannot be loaded because running scripts
is disabled on this system. For more information, see about_Execution_Policies
at https:/go.microsoft.com/fwlink/?LinkID=135170.
```

PowerShell's execution policy needs to be updated to allow `.ps1` scripts to be
run.
To do this, run the following in an elevated PowerShell prompt:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

If admin privileges are not available,
the script can be run using the following command:

```powershell
powershell.exe -ExecutionPolicy Bypass -File ./tools/build_config/build.ps1 -build
```
