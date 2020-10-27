[<-previous](./0016-use-double-array-in-memory-for-pixel-data.md) |
next->

# 17 - Separate absolute and relative indexing APIs in pixel array

Date: 2020-Oct-15

## Status

Accepted

## Context

The pixel array within an SQW object can be too large to fit into memory.
To avoid running out of memory, the object holding the pixel array can be
file-backed.
This means that only a "page" of the pixel array is loaded into memory at any
one time.

Therefore two possible ways to index into the pixel array exist:

1. **Absolute index**:
_The position of the pixel in the full, file-backed, pixel array_.

2. **Relative index**:
_The position of the pixel in the currently loaded page of pixel data._

## Decision

There will be two separate APIs for accessing data,
these APIs distinguish between the two types of indexing.

1. **Perform absolute indexing  using `get_` methods:**

    Obtaining a subset of pixels or pixel data by absolute index will be
    possible using a `get_` method.
    For example, the following will retrieve pixels 100-200 by absolute index:

    ```matlab
    pixels.get_pixels(100:200)
    ```

    Similarly, to retrieve a range of data from particular pixel array fields:

    ```matlab
    pixels.get_data({'signal', 'variance'}, 100:200)
    ```

    At time of writing, there are no plans to implement similar `set_`
    methods with absolute indexing.
    If there becomes a requirement for setters with absolute indexing,
    these should follow a similar syntax.
    For example, the following should set signal and variance from absolute
    index 100 to 200, to zero:

    ```matlab
    set_data({'signal', 'variance'}, 100:200, zeros(2, 101));
    ```

2. **Perform relative indexing using attribute:**

    Obtaining pixel data using an attribute will return just the data for the
    currently cached page.
    Hence, indexing into these attributes will be relative.
    For example, the following will retrieve the signal values of pixels 10-20
    in the currently cached page:

    ```matlab
    pixels.signal(10:20)
    ```

    Setting of pixel data will be possible using attributes and relative
    indexing.
    For example the following will set pixels 1 to 20 on the current page to
    zero:

    ```matlab
    pixels.signal(1:20) = 0
    ```

## Consequences

- Users and developers will need to be made aware of the distinction between
the two methods of indexing.
This should be done through documentation.

- When using attributes (e.g. `.signal`),
it should usually be accompanied by a `while has_more()` loop,
looping through pages.
At the point of calling a `get_` method,
a `while has_more()` loop will usually not be necessary.
