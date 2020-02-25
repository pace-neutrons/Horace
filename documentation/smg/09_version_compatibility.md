# Version Compatibility



For each MATLAB release, MathWorks define a limited compatibility matrix of libraries and compilers.

Information on compiler compatibility is available from the [MathWorks](https://uk.mathworks.com/support/requirements/previous-releases.html) site. This does not document information about library dependencies.


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
| <b>Fortran</b> |       |  | |  | |  |  |
|Windows (Intel [1]) | XE 2019 |y|y|||||
|                    | XE 2018 |y|y|y||||
|                    | XE 2017 |y|y|y|y|y||
|                    | XE 2016 ||y|y|y|y||
|                    | XE 2015 ||y|y|y|y||
|                    | XE 2013 ||||y|y|y|
|                    | XE 2011 ||||||y|
|Linux (gFortran) | 6.3.x | y | y | y | y |  |  |
|                 | 4.9 | | |  | | y |  |
|                 | 4.7.x |   | |  | |  | y |
|Mac (Intel [2]) | XE 2019 |y|y|||||
|                    | XE 2018 |y|y|y||||
|                    | XE 2017 |y|y|y|y|y||
|                    | XE 2016 ||y|y|y|y||
|                    | XE 2015 ||y|y|y|y||
|                    | XE 2013 |||||y|y|

Notes:

1. Intel Parallel Studio 2015-2019; Intel Visual Fortran Composer 2011-2013
2. Intel Parallel Studio 2015-2019; Intel Fortran Composer 2013

| HDF5 | | R2019b | R2019a | R2018b | R2018a | R2017b | R2015b |
| :--- | --- | :---: | :---: | :---: | :---: | :---: | :---: |
| | 1.8.12 | y | ? | y | ? |  y |  y |
| <b>MPI</b> |    |  | |  | |  |  |
| Windows (MSMPI) | 8.0.12438 | y | | y | y | | n/a |
| Linux (MPICH) | 1.4.1p1 | y | | y | | | n/a |
