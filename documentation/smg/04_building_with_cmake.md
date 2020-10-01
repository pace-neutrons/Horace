# Building with CMake

## Build dependencies

A developer building Herbert/Horace will need to install:

- [Matlab](https://www.mathworks.com/products/matlab.html) >= 2018b
  - on Linux the desired Matlab version must be on the path when running the
  script
  - on Windows, by default, the latest version is found via the registry
- [CMake](https://cmake.org/download/) >= 3.7
  - must be on the path for both Windows and Linux
- System compiler:
  - Linux: [GCC](https://gcc.gnu.org/) >= 6.3.0
  - Windows:
  [Visual Studio](https://visualstudio.microsoft.com/downloads/) >= 2017

## Using build scripts

Horace and Herbert contain PowerShell and Bash scripts named `build.[ps1|sh]`.
These scripts provide an easy way to build Herbert/Horace on Windows or Linux.
Theses same scripts are used to build Horace and Herbert on the CI servers,
so they are tested regularly.

A developer can build using default options with the `[-]-build` flag.

From Herbert/Horace's root directory:

PowerShell:

```powershell
./tools/build_config/build.ps1 -build
```

Bash:

```bash
./tools/build_config/build.sh --build
```

_(Note Bash uses two dashes (`--`) whilst PowerShell uses one.)_

Generally, the default build options will be sufficient,
but there are several configurable parameters.
Both scripts have a `help` flag which display the available actions:

PowerShell:

```powershell
./tools/build_config/build.ps1 -help
```

Bash:

```bash
./tools/build_config/build.sh --help
```

### Notes

If, when running the PowerShell script,
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

## Using CMake directly

CMake provides a way to generate build files across multiple platforms. It also
ships with a script to aid in compiling Matlab mex libraries.

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
4. Make sure to also select your platform/architecture, this should also match
your Matlab version: if you installed a 64-bit version of Matlab choose x64 as
the platform.
5. Now click finish in the dialogue. CMake will find the Matlab compiler and
various libraries.
6. Now click generate. The build files should be generated inside the DLL
directory. On Windows you can open the `<Horace Root>/build/Horace.sln` file in
Visual Studio and build the targets. On linux you can `cd` into the
`<Horace Root>/build/` directory and run `make` depending on the generator you
selected.
7. The mex files will be written into `horace_core/DLL`.

To do steps 2-6 using the command line you can use the following commands (for
linux use `-G "Unix Makefiles"`):

`$ cmake -S <Horace Root> -B <Horace Root>/build -G "Visual Studio 15 2017 Win64"`

`$ cmake --build <Horace Root>/build --config Release`

There are known issues running mex files compiled using old versions of CMake
on new Matlab versions.
If you get an error like `Invalid MEX-file: Gateway function is missing`,
try updating CMake.
CMake v3.14 has been confirmed to work for Matlab R2019b.
