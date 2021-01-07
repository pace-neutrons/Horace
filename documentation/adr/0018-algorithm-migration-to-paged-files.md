[<-previous](0017-separate-absolute-and-relative-indexing-APIs-in-pixel-array.md) |
[next->](0019-update-release-notes-every-pr.md)

# 18 - Algorithm migration to paged implementations

Date: 2020-Oct-15

## Status

Accepted

## Context

The codebase includes two different `cut()` methods:
 - one in the SQW object API which operates on the in-memory SQW data
 - one is a function that takes a `.sqw` filename and operates directly on that (on-disk)

The on-disk implementation is significantly slower and users are aware of this.
If a 'too large' file is operated on in-memory, an OutOfMemory Error will be thrown and the process will fail.
A typical use-case for `cut` consists of taking an initial cut from a large dataset held in a file
and storing this cut in memory as an `sqw` or `dnd` object.
Subsequent cuts are in-memory object to the in-memory object.

As a consequence:
 - users are required to develop (and test) separate scripts for each API
 - users make a conscious choice between “in memory (fast)” and “on disk (slow)” operations.

Mantid have (multiple times) attempted to present seamless in-memory/on-disk operation to their users (for a slightly different use case).
Each time this either failed for technical reasons or because users did not embrace it,
and the attempts were abandoned.

One of driving forces for the current PACE project is the support of large datasets,
which are expected to be increasingly common and of increasing size.
The new SQW object has been designed around a paged `PixelData` object which holds data in memory, up to a configurable page size, and pages additional data from disk as it is required. Under this model:

 - an identical API is available for large and small datasets on small and large computers
 - the switch between in-memory and on-disk (paged) operation is automatic as dataset grows
 - the page size is a configuration parameter that is intended to be user configurable for the machines and datasets they’re using:
    - a large page size will offer better performance if the whole dataset fits in a single page,
    - a moderate page size appears optimal for datasets too large for system RAM
    - it is hard / impossible / undesirable to calculate optimal page size on a per-machine/per-file basis
- implementation of a single `cut()` method (or function) that operates on an SQW object (either `this` or one passed as an argument) operating through the public API and agnostic to the size of the datasets.

There are several algorithms that need to be updated to support large datasets.
Any updates must be made in such a way that algorithms function
as they currently do on "small" datasets.

During the migration scripts which make use of a
subset of the updated algorithms may be required to perform end-to-end testing with paged data.
These should not require code changes or the use of alternate APIs.


## Decision

- A new `pixel_page_size` argument for will be added to the SQW object.
The SQW class will to default to in memory operation (i.e. no paging)
if a page size is not passed explicitly to the constructor
until all code has been updated to support paged operation,

```matlab
% unpaged: default page size is 0/inf
s = sqw(filename)

% paged with specified page size
s = sqw(filename, 'pixel_page_size', page_size)
```
- a warning message will be output when operations are performed
  on dataset that requires paging to enable a user to understand the performance drop,

- all algorithms will be created following a common API pattern:

  1. `obj = algorithm(filename, ...)`: internally create a paged SQW object from the given file and execute the algorithm on the paged object. The SQW returned will be a smaller, in-memory object,
  2. `algorithm(filename, out_filename, ...)`: equivalent to (1) except the resulting SQW object will be saved to file instead of returned as an object. This provides a method to perform an algorithm that maps a large SQW file to another large SQW file,
  3. `obj = algorithm(sqw_obj, ...)`: execute the algorithm on the input object. Note that if a paged SQW object is passed in the return object will also be paged, so this must be used with caution during the migration,
  4. `algorithm(sqw_obj, out_filename, ...)`: equivalent to (3) except the resulting SQW object will be saved to file instead of returned as an object.
- All algorithm APIs will support additional optional arguments necessary for execution through the MPI Framework (e.g. an instance of a pre-initialized and started `ClusterWrapper`)

The example APIs for `cut` would be:
```matlab
% Pure in-memory operation (small file only)
s = sqw(infile)
slice = cut(s)

% Paged operation (in-memory for small file, paged for large file)
s = sqw(infile, page_size)
slice = cut(s) 		 % object => object

% Filename based API
slice = cut(infile)  % disk => object
cut(infile, outfile) % disk => disk
```


## Consequences

- The internal switch between in-memory and disk operations means
  the performance drop will happen at the point the dataset exceeds page size.
  This switch will present as a sudden, unexpected performance drop.

- Paging will not be generally enabled.
  All SQW object will continue to work with existing (unmodified) algorithms.

- Performance drops associated with paged will only occur if the user has called a filename API
  or passed an SQW object they have explicitly created as with a page size.
  The display of a console message will aid users in understanding the change.

- Paging can be switched “on” simply supporting developer activity.

- If paging is enabled, i.e. the filename API used, and the SQW file is less that page sized,
  the operation will be performed in memory giving improved performance.

- A single implementation of each algorithm will be created that will work for paged and in-memory data.

- The paged SQW file created internally by an algorithm's filename API must not be returned from the algorithm call.
  Doing so would "leak" paged data objects and result in unexpected failures elsewhere in the application.

- Existing algorithms will continue to work on **unpaged data**.
  The behaviour if they are executed on **paged** data is undefined.

  This situation will only arise if a paged `sqw` object is explicitly created by a user
  and passed in, or as a result of page "leakage" resulting from
  an error in the implementation of an algorithm.

- Once all algorithms are updated, the default behaviour of SQW will be changed
  from unpaged to paged.
  Any code in the wrapper methods removing paged intermediate objects may be dropped.

- Memory errors will be raised if a cut is larger than available RAM and no `outfilename` is specified.

- Memory errors will be raised if a SQW object is created from a file larger than available RAM.

- Specific algorithms will be revisited to resolve specific performance issues
  once the update is completed.

- Interaction with chunked MPI jobs will need to be managed. There is no requirement that default page-size and chunk-size are equal.