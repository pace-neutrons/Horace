# Intermediaries of Single Filebacked Operations
Date: 2023-01-11

## Objectives and problems to solve

Currently the implementation of single-filebacked objects is based upon a temporary file beinhg created as infrequently
as possible and modifcations to the sqw data taking place within that file. The issue with this mechanism is that while
it may result in less data being written if operations only modify components of the data (e.g. signal/variance for many
unary/binary ops) if a job fails or is cancelled partway through the user is left without a viable (or worse yet a
viable but incorrect/invalid object).

Thus, it was decided that the operation should only replace the temporary file once the full operation has been
completed and otherwise leaves behind a correct file and any intermediaries are cleared upon finalisation of an
operation.

Upon instantiating an `sqw` object from a file, several things take place and an `sqw` object is constructed with the
following structure:

- sqw
  - main header
  - pix == `PixelData` object
  - experiment info
  - headers

The `PixelData` object here is the object of interest.

## Prior Implementation

Prior to the refactor, there existed one object, `PixelData` which handled both in-memory and file-backed operations,
though was incomplete.

It also relied on creating multiple files of "pages" of partial pixel data. This would allow functions to be applied to
part of an `sqw` object, however, Horace does not support application to parts of `sqw`s, except through explicitly
creating a slice of an `sqw` object through `cut`, which creates a separate instance of `PixelData` anyway.

## Current Implementation

Following the refactor the `PixelData` object was changed to the following hierarchy:

- `PixelDataBase` - Abstract base class
  - `PixelDataMemory`
  - `PixelDataFileBacked`
- `PixelData` -- Exists only as a wrapper to allow tests to load old `PixelData` objects as new `PixelDataBase` format,
  cannot be manually instantiated.

`PixelDataMemory` is a simple problem to solve as all operations happen in-place at once in memory and are subsequently
saved to disc only upon a saveobj operation being called on the parent `sqw` object.

`PixelDataFileBacked`, however, is a trickier proposition as intermediary objects are created out of necessity (if the
object is to be file-backed it is implied to be too large to fit in memory all at once or at the very least it would be
inconvenient to do so); as such, the resulting product must be constructed piecemeal.

Upon the first operation being applied to the `PixelDataFileBacked` object, data is loaded from the sqw-file through
`faccess` routines in chunks (still called "pages"), the operation is applied to each chunk and then appended to a
temporary file (e.g. `sqw000015251.tmp_sqw`).

Following this first operation, any subsequent operations applied to the `PixelDataFileBacked` object with a temporary
file would instead load data from the temporary file (via a `memmapfile` which allows loading of segments of data from
file into memory through array indexing) and overwritten in-place in the file (through the `memmapfile`
interface) chunk-by-chunk.

Currently, the temporary file does not contain any headers or other information required for constructing an `sqw`
object and instead just contains raw pixel numbers.

## Proposed Implementation

While the object hierarchy will remain unchanged from the current implementation, concerns about half-completed
operations irreparably (or invisibly) corrupting pixels will require attention. To this end, it is proposed that all
operations on `PixelDataFileBacked` will result in a new temporary file being created and only upon completion of the
operation will the file be moved to overwrite the old temporary.

Access to properties can still be done through a `memmapfile` for loading data segments, however, since assignment will
no longer be done through `memmapfile`, it may be advantageous to consider strided loading.

The new implementation will also include writing the header-data into the temporary file, to allow it to be directly
loaded through `faccess` as an `sqw`. `saveobj` on a `PixelDataFileBacked` will simply change the name of the temporary
sqw to a more permanent name.
