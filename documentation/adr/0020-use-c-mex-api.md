[<-previous](./0019-update-release-notes-every-pr.md) |
next->

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
which provided challenges when writing the Matlab object serializer in C++.

TODO: do we have examples of where the C++ API did not work for our use-case?

## Decision

Herbert/Horace will continue to use the C API for new Mex functions.

## Consequences

- The C++ code we write will be compatible with all Matlab releases,
  including those older than R2018a.
- The C++ code we have written will be consistent with new code we write.
- We will not get the benefits of the newer C++ Mex API
  (e.g. smart pointers, [C++ class wrappers](https://www.mathworks.com/help/matlab/matlab-data-array.html?s_tid=CRUX_lftnav)).

_Note: this decision need not be binding,
but provides a guideline for us to be consistent.
If a use-case arises where using the C++ API is advantageous,
then there should be nothing stopping us from using it._
