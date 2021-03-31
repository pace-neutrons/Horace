# Pixel Data

## The Problems to Address

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

- It operates with "pages" of cached data.
  - The page size is specified on construction (in bytes).
  - Only a page size worth of pixels is loaded at any one time.
  - If all pixels fit in one page, all pixels are loaded.
  - The default page size is `realmax`, this means that,
    by default, exactly one page is used, as this value is very large.

- Temporary files hold changes to pixel data.
  - When pixel data is changed, the changes are written to a temporary file
    when the current page is cleared.
    This most often occurs when the next page is loaded.
  - Changes are _never_ written to the SQW file used in construction.
  - A logical array is held on the object that tracks which pages are "dirty".
  - If a page is "clean" the data is loaded from the SQW file, if the page is
    "dirty", it is loaded from a temporary file.
  - Each page has its own temporary file.

- It is a
  [`handle`](https://www.mathworks.com/help/matlab/matlab_oop/handle-objects.html)
  class.
  - To copy a `PixelData` object, you must explicitly call the `copy` method.
    This copy can be expensive, as all temporary files are also copied.
    The copies are new temporary files, managed by the new object.
    Clean pages (those without temporary files)
    are still backed by the original `sqw` file.
  - There is no "lazy-copy-on-assignment" as exists for Matlab value classes.

  The main reason for using a handle class was due to the file-backed nature of
  the object.
  As the data resides in a file, copies of `PixelData` objects are not copies of
  the data, and thus, the objects are not independent.

  Using a handle class is also convenient when working with setters.
  Handle classes allow you to do the following:

  ```matlab
  >> sqw_obj.data.pix.set_data('signal', zeros(1, pix.num_pixels));
  ```

  Whereas, using a value class, one must return and assign the class instance
  for the setter to take effect:

  ```matlab
  >> sqw_obj.data.pix = sqw_obj.data.pix.set_data('signal', zeros(1, pix.num_pixels));
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

- `PixelData` objects do not know about their binning.
  - The binning is defined by the `sqw` object's image.

### Saving Pixel Data

The `PixelData` class has no capacity of its own to save its data to an sqw file.
This is the responsibility of the sqw file savers;
in particular, `sqw_binfile_common.put_pix`.
This method, called when saving an `sqw` object,
loops over pixel pages and saves them to the `sqw` file.

There also exists `sqw_binfile_common.put_bytes`
which can be used to save arbitrary numeric data to an `sqw` file.
You can position the `sqw_binfile_common` instance's file handle at the start
of the `sqw` file's pixel array,
and save pixels directly to file this way.

This can be useful if you are performing an action on an sqw object's pixels,
and want to output directly to an sqw file,
rather than dealing with temporary files.
See the example on [avoiding temporary files](#avoiding-temporary-files)
for an example of how and where this is useful.

### Getters/Setters

All getters return data in-memory.
All setters must set data that is in memory.
Attempting to get or set data outside the pixel array range will throw an error.

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

>> tail_coordinates = pix.coordinates((end - 9):end);
>> size(tail_coordinates)
    ans =
      [4, 10]
```

All these properties work by slicing into the cached data array at the correct
column.
Attempting to get/set pixels outside the range of the current page
will throw an error.

All properties use [_relative indexing_](#Absolute-and-Relative-Indexing).

### Methods

Getter and setter methods are also provided.

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
The indexing argument attempts to mimic that of a normal Matlab array,
i.e. logical indices are allowed and indices can be given out of order.
However, it does not support indexing using `end`,
you can use the `num_pixels` property to achieve the same effect.

The getter methods have the advantage of being able to get/set multiple columns
at once.
This can be more efficient,
as only a single slice into the pixel cache is performed,
rather than a slice for each column (field).

```matlab
% The below examples are equivalent for a pixel data object with one page.
% Using the get_data method is more efficient as it performs fewer slices

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
            % As we are editing the cached data, the current page is marked as
            % dirty.
            obj.signal = obj.signal - scalar;

            % Check if there are any more pixels to load from file.
            while obj.has_more()
                % Move to the next page of data.
                % Since the current page has been marked "dirty", this 'advance'
                % dumps the page to a temporary file.
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

### Avoiding Temporary Files

It can sometimes be possible to avoid using temporary files when operating on pixels.

Take, the above [`minus` example](#simple-example) for the case of an sqw object.
If our desired output is not a file-backed `PixelData` object,
but a new SQW file, we can write the updated pixels directly to the output file,
instead of first storing them in temporary files and then re-combining on save.

```matlab
function minus(sqw_obj, scalar, outfile_path)
    %MINUS Subtract a scalar from every pixel in the input sqw object,
    % and save the output sqw object to `outfile_path`
    %
    % The input sqw object is not to be modified.
    %

    % Initialize an faccess object for our output file
    faccess_out = sqw_formats_factory.instance().get_pref_access(sqw_obj);
    faccess_out = faccess_out.init(sqw_obj, outfile_path);

    % Write everything up to pixels
    % This will also move the file handle to the position of the start of the
    % pixel array
    faccess_out.put_sqw('-nopix');

    % Get reference to PixelData object, note no copying as PixelData is a handle
    pix = sqw_obj.data.pix;

    % Make sure we're on the first page before beginning the loop
    pix.move_to_first_page();

    % Make the subtraction from the pixel's signal
    pix.signal = pix.signal - scalar;
    % Write the edited pixel cache directly to the output file
    faccess_out.put_bytes(pix.data);

    % Start loop over subsequent pixels
    while pix.has_more()
        % The `nosave` flag means changes to the cache are discarded on advance,
        % hence no temporary files are written.
        pix.advance('nosave', true);

        pix.signal = pix.signal - scalar;
        faccess_out.put_bytes(pix.data);
    end
end
% Now all pixels are saved, file footers must be written
faccess_out.put_footers();
```

The alternative to the above is performing two loops over the pixel data.
The first loop would be making the subtraction and writing the cached changes
to temporary files (on `pix.advance()`).
The second loop would be reading in those temporary files,
and then writing them to the output file.

### Managing Binning

Some algorithms require that pixels in different bins are operated on in
different ways.
In most cases, bins will cross pixel page boundaries,
so it takes some work to find which bins require which action.

As an example, consider performing addition between an `sqw` and a `dnd` object.
Each pixel in the `sqw` object, that belongs to bin `n`,
should have its signal increased by the value of the `dnd` object's signal in
bin `n`.

To make these cases easier, the function `split_vector_fixed_sum` was written.
This function will split the `npix` array
(the array that defines the pixel binning)
into chunks such that each chunk defines the binning for a page of pixel data.

```matlab
classdef PixelData < handle

    methods

        ...

        function add_sigvar(obj, image_data, npix)
            %ADD_SIGVAR Add a sigvar-like image data object to this pixel data
            % This is a simplified version of `binary_op_sigvar_` that exists
            % in Horace (we don't worry about error in this version).
            %
            % sigvar-like refers to an object that has a signal `.s` and error
            % `.e`.
            % Note that image_data's `.s` and `.e` fields are the same size as
            % npix. The fields contain one value for each bin defined by npix.
            % Also note that `sum(npix(:)) == obj.num_pixels`.
            %
            % This 'image_data' object could be a dnd. Hence each value in `.s`
            % represents the average signal for the given bin.
            % To add this to pixel data, you must generate "fake" pixel signal
            % data from the image. This is done by creating npix(bin_num)
            % signal values, each of which is equal to `.s(bin_num)` (so each
            % "fake" pixel has the average signal). This can then be added to
            % this object's signal.
            %
            % If this operation was performed all in memory, it would boil down
            % to:
            %   obj.signal = obj.signal + repelem(image_data.s(:), npix(:))
            %

            % Always move to the first page of data
            obj.move_to_first_page();

            % The given npix array defines the number of pixels in each image
            % bin.
            % Split this array up on page size, such that we get the number of
            % pixels in each bin for each page of pixel data.
            % `bin_idxs` is a [2xN] array where N is the number of npix chunks,
            % and each column is the start and end index of the range of bins
            % the npix chunk defines the binning of.
            [npix_chunks, bin_idxs] = split_vector_fixed_sum(npix, obj.base_page_size);

            for page_number = 1:numel(npix_chunks)
                % Get the signal at the bins for which the currently loaded
                % page of pixels contribute
                img_chunk = sigvar_obj.s(bin_idxs(1, page_number):bin_idxs(2, page_number);

                % "Smear" the sigvar image's signal, such that it has the same
                % number of elements as we have pixels in the current page.
                signal_to_add = repelem(img_chunk(:), npix_chunks{page_number});

                % Increment the current page's signal and move to the next page
                obj.signal = obj.signal + signal_to_add;
                obj.advance()
            end
        end

        ...

    end

end
```

## Things to Be Aware Of

- The underlying pixel data is stored in a 9xN array
  (where N is number of pixels).
  This means **it is efficient to slice full pixels** from the data,
  as data points for each pixel are contiguous in memory.
  **It is less efficient to extract data for pixel fields**
  (e.g. signal), as these data are not contiguous in memory (or on disk).

- Algorithms that transform pixel coordinates should update the **pixel range**.
  This specifies the minimum and maximum value for each coordinate.
  The range is a property on a PixelData instance (`pix_range`),
  it should be updated with the new coordinate limits.
  Preferably, the update should take place within the algorithm.
  This avoids the use of the `recalc_pix_range` method,
  which performs a loop over pixels.
  The pixel range is cached in file and on the object.

- Pixel data values are stored in single-precision in file.
  They are store in double-precision in memory.
  See [ADR 15](../adr/0015-store-pixel-data-in-single-precision.md)
