# Building with Matlab on IDAAAS

## Build dependencies

To build Herbert/Horace the following will need to be installed:

- [Matlab](https://www.mathworks.com/products/matlab.html) >= 2018b
  - on Linux the desired Matlab version must be on the path when running the
- System compiler:
  - Linux: [GCC](https://gcc.gnu.org/) >= 6.3.0
- MPI: 
  The Horace parallel MPI applications work with mpich-3.2. 

## Using build scripts

Two scripts are available within Horace, in Horace/admin folder

`horace_mex`  -- used to build all Horace mex files. Standard RHEL gcc compiler gcc-4.8.5 sufficient to work with this script.

`horace_mex_mpi`  -- necessary to compile MPI extension `cpp_communicator`. Modern C++ compiler necessary to build this code. (version 8 verified)


To enable recent version of the compiler on IDAAAS, one need to get IDAAAS developer machine. 
Necessary C++ compiler should be loaded by command:

`scl enable devtoolset-8 bash`

MPICH modules should be enabled by commands:

 - `module list`  -- list available modules
 - `module load mpi\mpich-3.2-x86-64` -- load appropriate mpich module
 - `module list` -- check if the module have been loaded and is available.


after enabling, GCC compiler should be configured from Matlab using standard command:

 `mex -configure C++`.

Then scripts run and report success if mex files were compiled successfully or failure if they were not.


