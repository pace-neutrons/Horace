# Matlab

The Horace and Herbert code bases are primarily written in Matlab, with some key routines written in C++.

Matlab is a [licensed product](https://uk.mathworks.com/pricing-licensing.html), for which ISIS has access to a number of licenses. 
In order to build, deploy and execute Horace in the various configurations a range of licenses will be needed.

The Matlab compiler (required to convert Matlab into an executable or library) is licensed separately to the main Matlab 

## Execution Environment

### Desktop

| Environment | Licence Required |
| ---  | :---: |
| Matlab API |    Y     |
| Python API |    N*    |

*: Compatible MCR must be installed

### Server

| Task | Licence Required (per node) |
| ---  | :---: |
| Matlab  |  Y  |
| Python  |  N*  |

*: Compatible MCR must be installed

## Build Server

### MATLAB Source

| Target Architecture | Licence Required |
| ---  | :---: |
| Windows | Y+ |
| Linux   | Y+ |
| MacOS   | Y+ |
| SCARF   | Y+ |

+: Matlab compiler license required

### C++ Source to Matlab function

| Target Architecture | Licence Required |
| ---  | :---: |
| Windows | N |
| Linux   | N |
| MacOS   | N |
| SCARF   | N |

The Matlab compiler used here is a wrapper around GCC with linked libraries.

## Parallel Toolbox

Currently we have Matlab–based parallel framework, covering full `gen_sqw` user task (3 parallel algorithms).

The parallelization is framework-agnostic, but performance depends on the underlying framework.

To run/test/compare performance of existing Matlab-based parallel framework:

- on a single node one needs a parallel computing toolbox licence for this node.
- on a cluster one needs a a parallel computing toolbox licence and the Matlab Distributed computing licence (a licence per participating cluster node)

Currently we have sufficient number of licenses to support the operations, but as our custom MPI based parallel framework is established, the need in these licenses will disappear.