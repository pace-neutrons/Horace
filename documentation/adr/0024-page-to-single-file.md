[<-previous](0023-error-format.md)
next->

# 24 - Page PixelData as single file

Date: 06-10-2022

## Status

Accepted

## Context

When performing file-backed operations, the [current implementation](0018-algorithm-migration-to-paged-files.md) of
`PixelData` uses multiple files to store the temporary files and subsequently rebuilds (concatenates) them into a new
structure when the SQW object is to be saved. While this might be efficient for partial (applied to subsections of data)
access patterns, this is not the case for either full-sequential (applied to whole data [unary/binary ops]); where
opening and closing files carries a time-cost, and for parallel ensuring good load balancing may involve two processes
operating on the same file simultaneously; or random-access (applied with variable stride across broad sections of data
[cut]). In the Horace code, all operations are performed in either of these two modes, and as such it is disadvantageous to
use multiple temporary files, and instead a single file may be better.

The reasoning behind a single file being better lies in several factors:

- File system handling of multiple requests for opening can lead to slowdown as system looks up indices. These requests
  come for every request to open a new file, which will happen multiple times with a series of files.
- Multiple files may not be sequential on disc leading to inefficient long seek times as multiple processors attempt to
  request different areas.
- Limitations on number of file-handles given by OS.
- Cost of separation, recombination
- Need to write approximately the same amount of data in total for sufficiently large S(**Q**, w) objects anyway, which
  are the only kind which would be file-backed.

## Decision

It was decided that the current implementation of multiple-file pages should be rewritten to manage pages through one
file and simply scan through that file as the main means of paging. This will maintain the existing interface, but
replace the file-opening-closing functions with seek and read operations. This will reflect the interfaces already used
in the cut operations.

## Consequences

- Features will have to be rewritten to support new scheme.
  - Advance/Move pages
  - Has more
  - PixelTmpFileManager features
  - Get pix in range
- Cut will need to adopt new features
- External interface must be maintained to avoid breaking existing features and user scripts.
