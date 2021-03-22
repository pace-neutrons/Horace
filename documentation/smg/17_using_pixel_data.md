# Using Pixel Data

## The Problem to Address

To address the following problems, a `PixelData` class was proposed.

### Large Data

Pixel data in SQW objects can often be very large.
For some SQW objects, it can be impossible (or inefficient) to hold all pixels
in memory at one time.
It was required that Horace algorithms be able to operate on these large data.

#### Large Data - Solution

To enable use of Horace algorithms on large SQW objects,
an interface to pixel data was proposed.
With this interface, Horace algorithms could access pixel data on disk
in a similar way to which they access pixels in memory.
The object could wrap the raw pixel data and/or a file handle,
and provide getters/setters for the data.

The concept of "pages" of data would exist in the `PixelData` class.
Instances of the class could load, and operate on, a "page" of data at a time.
The class would have a `has_more()` method to indicate whether data subsequent
to the currently loaded page exists on disk.
This would allow looping over pixel data in a `while` loop:

```matlab
while pixel_data.has_more()
    % operate on pixel page
end
```

### Data API

Pixel data, in memory, was stored as a raw Matlab array.
Pixel data fields (e.g. signal, variance etc.) were accessed using indexing:

```matlab
>> pix_signal = sqw_obj.data.pix(8, :);
>> pix_coordinates = sqw_obj.data.pix(1:4, :);
```

This meant that accessing data required previous knowledge of the data structure;
to get the signal, one needed to know it is stored in column 8.
It also meant that actions performed on pixel data relied on the array's structure.
This would cause issues if it was ever advantageous for the structure of the
pixel data to be changed.

#### Data API - Solution

It was proposed that the `PixelData` class would provide getters/setters for
pixel data fields.
This would not assume users of the class had knowledge of the underlying data
structure.
It would also mean that, if the pixel data structure were to change,
other code using pixel data could remain the same.

### Extendability

There was also a requirement that the pixel data be extendable,
i.e. users should be able to add extra named columns to the data.

#### Extendability - Solution

The proposed `PixelData` class would allow addition of extra data per pixel,
in named elements.
These data could be retrieved using a getter that takes a char/string argument.

### Parallelism

As pixel data is often large, it's advantageous to perform operations on the
data using distributed memory parallelism.
To aid in this, a simple way of "chunking" the data between workers was required.

#### Parallelism - Solution

The ability to move to specific pages of pixel data was proposed to solve this
problem.
Using the `move_to_page(page_num)` method allows a worker to position itself at
a particular point in the pixel data.
This reduces distributing pixels between workers to a function of:
the number of workers, the number of pixel, the page size.
Each worker can receive its start and end page index from the head node,
and operate on those pixels.

## The PixelData Class

### Principles

- It works on "pages" of cached data.
  - The page size is specified on construction (in bytes).
  - Only a page size worth of pixels is loaded at any one time.
  - If all pixels fit in one page size, all pixels are loaded.

- Temporary files hold changes to pixel data.
  - When pixel data is changed, the changes are written to a temporary file
    when the current page is cleared.
    This most often occurs when the next page is loaded.
  - Changes are _never_ written to the SQW file used in construction.
  - A logical array is held on the object that tracks which pages are "dirty".
  - If a page is "clean" the data is loaded from the SQW, if the page is "dirty"
    it is loaded from a temporary file.
  - Each page has its own temporary file.

- It is a
  [`handle` class](https://www.mathworks.com/help/matlab/matlab_oop/handle-objects.html).
  - To copy a `PixelData` object, you must explicitly call the `copy` method.
    This copy can be expensive, as all temporary files are also copied.
  - There is no "lazy-copy-on-assignment" as exists for Matlab value classes.

  The main reason for using a handle class was due to the file-backed nature of
  the object.
  As the data resides in a file, copies of `PixelData` objects are not copies of
  the data, and thus, the objects are not independent.

  Using a handle class is also convenient when working with setters.
  Handle classes allow you to do the following:

  ```matlab
  >> sqw_obj.data.pix.signal = zeros(1, pix.num_pixels);
  ```

  Whereas, using a value class, one must return and assign the class instance
  for the setter to take effect:

  ```matlab
  >> sqw_obj.data.pix = sqw_obj.data.pix.signal = zeros(1, pix.num_pixels);
  ```

- Data is loaded on access.
  - No data is loaded from file on construction.
  - All public data accessors _must_ check that data is loaded before returning data.

  This is advantageous as it prevents performing potentially expensive
  IO operations when pixels are not used.
  For example, a user may wish to load an SQW object and plot the image data.
  This does not require pixels, so time and memory is wasted loading what could
  be gigabytes of data.
  Note that this also means it is free to move to a given page of data after
  constructing the object.

- Pixel data are held in memory as `double`s.
  This is in contrast to in file (including temporary page files),
  where pixels are stored as `single`.
  See [ADR 15](../adr/0015-store-pixel-data-in-single-precision.md).

### Getters/Setters

All getters return data in-memory.
All setters must set data that is in memory.

### Properties

There are
[dependent properties](https://www.mathworks.com/help/matlab/matlab_oop/access-methods-for-dependent-properties.html)
for each of the nine fields of pixel data.
There are also dependent properties for common groups of properties,
e.g. `.coordinates` retrieves `u1`, `u2`, `u3` and `dE`.
These properties can be used to retrieve and set data _in the current page_.

```matlab
>> size(pix.signal)
    ans =
      [1, pix.num_pixels]

>> head_run_idx = pix.run_idx(1:10);
>> size(head_run_idx)
    ans =
      [1, 10]

>> tail_coordinates = pix.coordinates((end - 10):end);
>> size(tail_coordinates)
    ans =
      [4, 10]
```

All these properties work by slicing into the cached data array at the correct
column.

All properties use [_relative indexing_](#Absolute-and-Relative-Indexing).

### Getters/Methods

Getter and setter methods are also provided.
You cn

```matlab
>> coordinates = pix.get_data('coordinates');
>> class(coordinates)
    ans =
      'double'

>> pix.set_data({'signal', 'variance'}, zeros(2, pix.num_pixels));
>> size(pix.get_data({'signal', 'variance'}, 1:100))
    ans =
      [2, 100]

>> sub_pix = pix.get_pixels(3001:4000);
>> class(sub_pix)
    ans =
      'PixelData'
>> sub_pix.num_pixels
    ans =
      1000
```

These methods provide ways to retrieve data from the full pixel data array,
whether that data is in memory or is in a file.
They also have the advantage of being able to get/set multiple columns at once.
This can be more efficient, as you're performing a single slice, instead of
multiple.

```matlab
% Below examples are equivalent, but using the get_data method is more
% efficient as it performs fewer slices

% Performs one slice over the pixel array
>> run_sig_var = pix.get_data({'run_idx', 'signal', 'variance'});

% Performs one slice for each property access
>> run_sig_var = zeros(3, pix.num_pixels);
>> run_sig_var(1, :) = pix.run_idx;
>> run_sig_var(2, :) = pix.signal;
>> run_sig_var(3, :) = pix.variance;
```

All getter/setter methods use [_absolute indexing_](#Absolute-and-Relative-Indexing).

#### Absolute and Relative Indexing

Absolute indexing refers to indexing into the full pixel array.
Relative indexing refers to indexing into the current page of pixels.

So, suppose a `PixelData` object interfaces a file which contains 100 pixels,
with a page size of 10 pixels.
Then the following holds:

```matlab
>> pix.num_pixels
     ans =
       100
>> pix.move_to_page(3);
>> all(pix.signal(1:6) == pix.get_data('signal', 21:26))
     ans =
       true
```

There exists a private utility function that can perform the conversion between
these index types.

See
[ADR 17](../adr/0017-separate-absolute-and-relative-indexing-APIs-in-pixel-array.md)
for the decision record on this.

## Implementing File-Backed Algorithms

### Simple Example

Suppose we wish to subtract some constant background from an SQW object.
This requires that we subtract some constant from the pixels' signal.
For this we could implement a `minus` function,
(in reality we have a general `do_binary_op` function).
This can be performed in a `while` loop over pixels.

```matlab
classdef PixelData < handle

    methods

        ...

        function minus(obj, scalar)
            %MINUS Subtract a scalar from every pixel's signal
            %
            % Input:
            % -----
            % scalar  A scalar double.
            %

            % Never assume we're on the first page.
            % If we are already on the first page, this call only costs one
            % integer comparison
            obj.move_to_first_page();

            % Subtract scalar from every value in cache.
            % If there is no data in the cache, this call will load that data
            % from file and then perform the operation.
            obj.signal = obj.signal - scalar;

            % Check if there are any more pixels to load from file.
            while obj.has_more()
                % Move to the next page of data.
                % This call dumps the previous page to a temporary file and
                % marks the page as "dirty".
                % It then clears the cache, and increments the internally held
                % `page_number`.
                obj.advance();

                % This call will now load the data for `page_number` and
                % perform the subtraction.
                obj.signal = obj.signal - scalar;
            end
        end

        ...

    end
end
```
