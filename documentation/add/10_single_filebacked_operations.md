# Intermediaries of Single Filebacked Operations
Date: 2023-01-11

## Objectives and problems to solve

Currently the implementation of single-filebacked objects is based upon a temporary file being created as infrequently
as possible and modifications to the sqw data taking place within that file. The issue with this mechanism is that, while
it may result in less data being written if operations only modify components of the data (e.g. signal/variance for many
unary/binary ops), nevertheless if a job fails or is cancelled partway through, the user is left without a viable (or worse yet a
viable but incorrect/invalid) object.

Thus, it was decided that the operation should only replace the temporary file once the full operation has been
completed and otherwise leaves behind a correct file, and any intermediaries are cleared upon finalisation of an
operation.

Upon instantiating an `sqw` object from a file, several pieces of data are loaded and an `sqw` object is constructed with the
following structure:

- sqw
  - `main_header`
  - `pix` => `PixelData` object
  - `data` => `dnd` object
  - `experiment_info`
  - `detpar`

The `PixelData` object here is the object of interest.

## Prior Implementation

Prior to the refactor, there existed one class, `PixelData` which handled both in-memory and file-backed operations,
though this was incomplete in its handling of both.

It relied on creating multiple files of "pages" of partial pixel data. This would, in principle, allow functions to be
applied to part of an `sqw` object; however, Horace does not support application to parts of `sqw`s, except through
explicitly creating a slice of an `sqw` object through `cut`, which creates a new instance of `PixelData`.

## Current Implementation

Following the refactor the `PixelData` class was changed to the following hierarchy:

- `PixelDataBase` - Abstract base class
  - `PixelDataMemory`
  - `PixelDataFileBacked`
- `PixelData` -- Exists only as a wrapper function to allow tests to load old `PixelData` objects as the new
  `PixelDataBase` format cannot be manually instantiated and when called manually results in a warning being issued..

The refactor of `PixelDataMemory` immediately loads all data from the file into memory, which allows all operations
happen in-place, `PixelDataMemory`s are only written to disc upon a `save` call on the parent `sqw` object.

`PixelDataFileBacked`, however, is requires intermediary objects are created out of necessity (if the object is to be
file-backed it is implied to be too large to fit in memory all at once or at the very least it would be inconvenient to
do so); as such, the resulting product must be constructed sequentially.

Upon the first operation being applied to the `PixelDataFileBacked` object, data is loaded from the `.sqw` file through
 via a `memmapfile` interface which allows loading of segments of data from file into memory through array indexing. The
 concept of "pages" still exists for the purpose of iterating through the object, but these are all chunk-wise loads of
 information via the `memmapfile` interface.

These temporary files are handled by a `TmpFileHandler` object which creates a new file with a name derived from the
original (e.g. from an original `test.sqw` creates `test.tmp_000015251`) and handles the clearing of temporary objects
when leaving scope. The reason for appending the `.tmp_...` to the end is to avoid an explosion of random numbers in the
case of a sequence of operations on temporary objects.

If an object is created through the `PixelDataFileBacked.get_new_handle` interface, the temporary file does not contain
any headers or other information required for constructing an `sqw` object and instead just contains raw pixel numbers.
Should the temporary be created from sqw `get.new_handle_relevant` however, headers will be written into the temporary
file allowing direct creation of an `sqw` from the temporary file.  `saveobj` on such a `PixelDataFileBacked` will
simply change the name of the temporary sqw to a more permanent name via a file rename rather than a copy.
