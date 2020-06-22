[<-previous](0014-use-jenkins-for-network-path-storage.md) | [next->](0016-use-double-array-in-memory-for-pixel-data.md)

# 15 - Store Pixel data in single precision

Date: 2020-Jun-10

## Status

Accepted

## Context

The pixel data is a N-row array of detector-element data, where N is O(2^32) and is expected to grow by an order of magnitude over the lifetime of Horace.

The current (Horace 3.4) SQW data file stores data as single-precision (float32) values. Previous versions of the file format stored the pixel data as double-precision (float64) values. 

Read/write of full SQW files scales linearly with file size and for a "typical" data file can take an hour on a desktop machine or 20-30 minutes on a parallel file system. As most of the data contained within the SQW file is the pixel data, the conversion halved the file size and consequently halved the time required to perform read/write operations.  

The raw data is typically captured with precision not exceeding that which my be represented in a single precision value.

## Decision

The data pixel data array will be stored as single-precision floats.

## Consequences

- Rounding errors will need to be considered when performing a sequence of operations on data
- It is likely that integer valued data stored in this array exceed the capacity of the float32 value within a few years
- No changes required to legacy I/O routines