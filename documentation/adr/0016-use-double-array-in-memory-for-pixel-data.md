[<-previous](0015-store-pixel-data-in-single-precision.md) |
[next->](0017-separate-absolute-and-relative-indexing-APIs-in-pixel-array.md)

# 16 - Use double array for in-memory Pixel data

Date: 2020-Jun-10

## Status

Accepted

## Context

Pixel data will be stored on disk as single precision (float32) data.

MATLAB's default numeric data type is `double` (float64).
Mixing `single` and `double` data in calculations produces a `single` result.

Options are to:

1. store data in `single` precision and extend the data to `double` precision before sequences of arithmetic operations are performed to reduce impact of rounding errors

2. store data in `double` precision and reduce the data to `single` precision before evaluation of performance intensive operations

Long chains of function calls are executed within some algorithms (e.g. TobyFit). If data is held in single precision, the accumulated rounding errors are likely to introduce qualitative changes in the results. The functions called in these chains are part of the larger Horace toolkit.

Significant performance improvements can be seen in some algorithms when performed on `single` precision rather than `double` data..

Pixel binning can be performed in both MATLAB and C++ code.
The two routines can result in inconsistent binning due to rounding errors.

## Decision

Pixel data will stored internally as an array of MATLAB doubles and converted on read or write.

Access to the data through the PixelData class API will return `double` values.

## Consequences

- Individual functions that use single precision data for performance optimization (e.g. sorting) will be required to convert data on input and output.
- Rounding errors accumulated during calculations will typically remain smaller than the signal underlying signal.
- Calculated data values will be truncated when written to file.
- The recomputation of pixel coordinates by different routines in `TobyFit` and `gen_sqw` means rounding errors may result in pixels to be binned differently -- these differences should be considered and if possible eliminated.
- There is no requirement to maintain `single` and `double` precision implementations of most toolkit functions.
