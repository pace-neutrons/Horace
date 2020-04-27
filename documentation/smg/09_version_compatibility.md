# Version Compatibility

For each MATLAB release, MathWorks define a limited compatibility matrix of libraries and compilers.

Information on compiler compatibility is available from the
[MathWorks](https://uk.mathworks.com/support/requirements/previous-releases.html)
site. This does not document information about library dependencies.

## Compilers

| C++  |    | R2019b | R2019a | R2018b | R2018a | R2017b | R2015b |
| :--- | --- | :---: | :---: | :---: | :---: | :---: | :---: |
|Windows | VS2019 | y | y |  | |  |  |
|        | VS2017 | y | y | y | y | y |  |
|        | VS2015 |  | y | y | y | y | y |
|        | VS2013 |  |  |  | y | y | y |
|        | VS2012 |  |  |  | |  | y |
|Linux (GCC) | 6.3.x | y | y | y | y |  |  |
|            | 4.9.x |  | |  | | y |  |
|            | 4.7.x |  | |  | |  | y |
|Mac (xCode) | 11.x  | y | |  | |  |  |
|            | 10.x  | y | y | y | |  |  |
|            | 9.x  | y | y | y | y | y |  |
|            | 8.x  |  | | y | y | y |  |
|            | 7.x  |  | |  | | y |  |
|            | 6.x  |  | |  | |  | y |
|            | 5.1+  |  | |  | |  | y |

### Libraries

| HDF5 | | R2019b | R2019a | R2018b | R2018a | R2017b | R2015b |
| :--- | --- | :---: | :---: | :---: | :---: | :---: | :---: |
| | 1.8.12 | y | y | y | y |  y |  y |
| **MPI** |    |  | |  | |  |  |
| Windows (MSMPI) | 8.0.12438 | y | y | y | y |   | n/a |
|                 | 5.0.12435 |   |   |   |   | y | n/a |
| Linux (MPICH2) | 1.4.1p1 | y | y | y | y | ? | n/a |
