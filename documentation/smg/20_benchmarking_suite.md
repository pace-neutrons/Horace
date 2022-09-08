# Benchmarking Suite

### Sep 6. 2022

## Introduction

As of the latest version Horace has a benchmarking suite to make analysis of timings of particular
routines easier. This document will detail the framework, scope, usage and utility of the
benchmarking suite as a whole.

## Structure

The structure of the benchmarking suite is contained entirely within the `_benchmarking` folder in
Horace root akin to the `_test` folder. Within the folder are subfolders named `bm_<function>` which
contain the benchmarks and details for the given function. Within each folder there is are 3 types
of file:

```
benchmark_<function>
gen_bm_<function>_data
test_bm_<function>_<info>
```

`benchmark_function` is the access function which runs the targetted profiling on the function in
question, `gen_bm_<function>_data` generates data or cuts of the requested size for use in
`benchmark_function`.


## Scope

The benchmark suite currently covers the following functions:
```
combine_sqw
func_eval
sqw_eval
tobyfit_simulate
cut_sqw
gen_sqw
tobyfit_fit
```

for different data sizes, those sizes are `largeData`, `mediumData`, `smallData`, the definitions of
which change depending on the function being run. In general, `smallData` ~10^7 elements, `mediumData`
~10^8 elements, `largeData` ~10^9 elements and 10^4/5/6 elements for 1D/2D/3D operations respectively.

There are standard defined benchmarks for combinations of tests including:
- Number of cores
- Number of datasets
- Size of datasets
- Dimensionality of data (i.e. 1D, 2D, 3D, 4D cuts)

## Execution

The Benchmarking framework exploits the existing MATLAB xunit framework in the Horace
repository. This means that individual benchmarks may be run using the standard
```MATLAB
runtests [file:[test]]
```
syntax.

There also exists the `benchmark_horace` analogue to the `validate_horace` script which runs all
registered benchmarks. There is also the CMake target `benchmark_all`, which generates the data and
runs the benchmarks for the currently built target.

Should the user wish to run a custom benchmark, each benchmark folder contains a
`benchmark_<function>` function. These are interfaces to run a standard benchmark with custom
parameters.

## CI

The benchmarking suite is designed so as to be included into the CI system and take frequent
measurements of the time taken for particular key routines of Horace (discussed in [scope](#Scope)).

The benchmarking suite will produce a number of `.csv`s which will be recorded as Jenkins artefacts
which will allow tracking of performance improvements or degradation with respect to historical
changes to master.

Ideally we can use a Jenkins plugin to process these `.csv`s and make recordings and graphs of key
measures in the benchmarking. Failing that, a Python script can be developed to produced graphs and
these can be recorded as artefacts within the system too.
