[<-previous](./0019-update-release-notes-every-pr.md) |
[next->](./0021-errors-and-warnings.md)

# 20 - Use C Mex API (rather than C++)

Date: 2021-Jan-20

## Status

Accepted

## Context

Matlab has two Mex APIs that can be used by C++ code:
the [C API](https://www.mathworks.com/help/matlab/cc-mx-matrix-library.html)
or the
[C++ API](https://www.mathworks.com/help/matlab/cpp-mex-file-applications.html).
The C++ API is relatively new and is therefore only compatible with Matlab releases
[R2018a and later](https://www.mathworks.com/help/matlab/matlab_external/choosing-mex-applications.html#mw_d3e64706-faf9-486f-ab58-1860c63564d8).

Throughout the Herbert and Horace codebases only the C API has been used.
This is primarily due to the fact that Herbert and Horace pre-date the C++ API.

The C++ API contains restrictions on directly accessing Matlab memory,
this provided challenges when writing the Matlab object serializer in C++.
The API does not allow access to the underlying memory of the Matlab objects,
and the C++ objects had varying sized headers.
This caused problems when attempting to perform copies and casts:
the underlying data needed to first be copied via the C++ API,
and only then could a `memcpy` be performed by the serializer.
This meant there were three copies of the data present at one time,
which is not desirable for large objects (e.g. pixel data).

## Decision

Herbert/Horace will continue to use the C API for new Mex functions.

## Consequences

- The C++ code we write will be compatible with all[<sup>[1]</sup>](#ref_1)
  Matlab releases, including those older than R2018a.
- The C++ code we have written will be consistent with new code we write.
- We will not get the benefits of the newer C++ Mex API
  (e.g. smart pointers, [C++ class wrappers](https://www.mathworks.com/help/matlab/matlab-data-array.html?s_tid=CRUX_lftnav)).

_Note: this decision need not be binding,
but provides a guideline for us to be consistent.
If a use-case arises where using the C++ API is advantageous,
then there should be nothing stopping us from using it._

---

_<a name="ref_1">
</a><sup>[1]</sup> This comes with a caveat when using complex numbers._

_In R2018a Matlab introduced the
[interleaved complex API](https://www.mathworks.com/help/matlab/matlab_external/matlab-support-for-interleaved-complex.html),
which stores complex numbers as
`[real_1, imag_1, real_2, imag_2, ..., real_n, imag_n]`.
This differs in releases R2017b and earlier, where complex numbers were stored
in two separate arrays, one for the real parts one for the imaginary.
You switch between which API to use in Mex files by defining the macro
`MATLAB_DEFAULT_RELEASE` to be `R2017b` or `R2018b`.
Or by passing the `-R2017b` or `-R2018b` flag to Matlab's `mex` command.
To remain compatible with older Matlab versions we must compile with the
`-R2017b` flag._

_For full compatibility, you can write implementations for both APIs and
use the `MX_HAS_INTERLEAVED_COMPLEX` macro and preprocessor directives
(`#if`, `#else` etc) to switch between them._
