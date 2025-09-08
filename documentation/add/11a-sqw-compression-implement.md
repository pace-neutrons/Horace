# Proposal for how to implement SQW compression

In the adjacent `add` document `11_sqw-compression`, the rationale for compressing 
pixel data in SQW objects when writing them to file is given. Here a methodology is 
given for how to implement that compression.

Topics discussed:
   - Method of compression: algorithm for how the data is compressed
   - Implementation of compression: code architecture for this algorithm and where it is located
   - Locations for compression and decompression: where in the code these operations are done
   - New faccess class structure
   - Refactoring issues arising, and optimization methods envisaged

## Method of compression

Currently 9 fields per pixel are stored in memory and written to file
   - qx, qy, qz, E (4 fields describing the wave-vector and energy of the pixel)
   - irun, idet, ien (3 fields describing the run, detector and energy parameters)
   - signal, error (2 fields describing the intensity and uncertainty of the signal)
As the first 4 can be reconstructed from the subsequent 3, they will be omitted on
writing and reconstructed on reading.
The irun,idet,ien triplet can be compressed into a single integer via
   - nindex = irun + nrun*(idet-1 + ndet*(ien-1))
where nrun, ndet and nen are the maximum values in the set of irun, idet and ien.
Thus 4 fields are eliminated and 3 fields are compressed to 1, leaving 3 fields net.

## Implementation of compression

A method on the sqw class nindex = compress_pixels(win,\[qx,qy,qz,E,irun,idet,ien],ibegin,iend)
where win is the containing sqw object for the pixels, will perform the above compression.
win provides the parameters nrun, ndet and nen. ibegin and iend are the first and last 
pixel indices to be compressed by this call; the reason for including this is given
below.

A method on the sqw class \[qx,qy,qz,E,irun,idet,ien,ibegin,iend] = decompress_pixels(win,nindex)
where win is the containing sqw object for the pixels, will perform the above 
decompression.
win provides the parameters nrun, ndet, nen and the method for calculating the 
wave-vector and energy, which is `calculate_qw_pixels2`. ibegin and iend are extracted 
in an additional step of the data decompression.

These methods are called within the faccess class instance reading or writing the 
files. This class will be a new class faccess_sqw_v5 (the current one is 
faccess_sqw_v4)
which will follow its predecessor in having a datum sqw_holder. In the event that this
is empty or otherwise invalid (by not returning true for isa(sqw_holder,'sqw'), 
the pixel data will not be compressed and the file will have the same contents as at
present.

These methods will be called at the point of reading or writing.

## Locations for compression and decompression

The locations here are those for the *current* faccess default faccess_sqw_v4. It is
intended that they will port to equivalent locations in the new faccess_sqw_v5 unless
specifically noted.

### Compression

These locations are the locations where the pixel data is written; it appears that 
there is only one such location.

`put_pix` is the method in horace_core\sqw\file_io\@faccess_sqw_v4\put_pix.m
It uses 2 calls to fwrite: 
   - at line 186 pixels *not* stored in a subclass object of PixelDataBase are written
     by a single fwrite. Compression should be done just before this line. As this will require
     additional memory of order a third of the original pixel data size, it may be
     desirable to page this into smaller chunks to prevent problems with allocation of
     memory.
   - at line 176 pixels which *are* stored in a subclass object of PixelDataBase
     are written by an fwrite per page. Again, compression should be done just before
     this line. For the moment it is considered that the page size is sufficient to
     control memory usage.

### Decompression

These locations are the locations where the file is read. There are more that one such 
location.

`get_pix_` is the method in horace_core\sqw\file_io\@faccess_sqw_v4\put_pix.m. It is
called from get_raw_pix. Note that another method `get_pix` exists as an alternative
caller of `get_pix_` but it appears only to be used for testing. This performs a single
fread and appears to correspond to the compression case where the data written is not
from a PixelDataBase subclass. The decompression should be done immediately after the
fread. Any additional paging done on compression should also be done here.

Note that this is also the method used for PixelDataMemory objects, where the method
`init_from_file_accessor_` calls `get_raw_pix` and hence `get_pix`. It is unclear how
the paging done in `put_pix` above for PixelDataMemory objects (included in the general
processing for PixelDataBase objects) is mirrored here where there is only a single fread.

For PixelDataFileBacked objects, the method `init_from_file_accessor_` is specialised
to used memmapfile. This is apparently an import from python which is less succesful 
in matlab. Critically here the decompression process breaks the symmetry of data size
between memory and file: the pixel record size here is now still 9 in memory but 3 on
disk. Consequently the memmapfile method cannot now obviously be used, and the older
pre-v4 straight read used instead. The symmetry between formats on reading and writing
should still be honoured.

### Other locations

Note that the get and put methods noted above in faccess_sqw_v4 are duplicated in
sqw_file_formatters in the directories below. It is not clear if they are used; they do
not appear to be called in any of the test suite.

## Construction of the new faccess

It is assumed that any existing sqw files will self-identify as faccess_sqw_v4 and
be read by Horace through those accessors (via the should_load method). 
New files created will be written as v5 and subsequently read by them as they identify
as v5. To make v5 the default accessor for new files, `horace_core\sqw\file_io\sqw_formats_factory` 
should be modified to add v5 to the list of supported accessors. This should then be
used for files of type 1 (sqw and sqw2). Other file types are unaffected by the
changes here, which are only due to pixel file storage - the other file types are DnD
types where there is only image data.

The new v5 accessor is identical to the existing v4 accessor apart from the envisaged 
changes to getting and putting pixel data. Consequently the two classes should be 
merged into a superclass with the pixel data changes implemented in a subclass.

It is unclear to what extent more converters between the classes are required. There
is no versioning of the sqw object, so once an earlier-format file is read, the result
is a current sqw object and any ommissions from its structure should already have 
been remedied in its reading. Hence no format converter is proposed.

## Refactoring and optimization

### Removal of couping between PixelData and faccess_sqw due to memmapfile

For the get_pix_ and put_pix methods, these are within the faccess class and will
automatically updated to use v5 when called. The PixelDataFileBacked version however
uses memmapfile within the `init_from_file_accessor_` method of the PixelData object, 
which transfers ownership of this specialisation outside the faccess class. It is 
proposed that the existing memmapfile usage be repackaged inside the get_pix_ method
if it is not replaced. While the present plan does not require using memmapfile, it
will be good to have an option for using it within get_pix_. This can be experimented
with once the basic implementation with direct primary read is in place. 

### Threading to parallelize read and decompression

Alex points out that the pixel decompression process may be slow, negating the 
advantages of compression, and that it should be done in a separate thread. In fact 
he proposes that two local threads be used, allowing the read and decompression 
operations to be done simultaneously. The order of operations is then

    - Thr.1: read page 1         Thr.2: Idle
    - Thr.1: read page 2         Thr.2: Decompress page 1
    - Thr.1: read page 3         Thr.2: Decompress page 2    
    - ....
    - Thr.1: read page N         Thr.2: Decompress page N-1
    - Thr.1: Idle                Thr.2: Decompress page N  

The use of two non-master threads leaves open the option to do non-i/o processing, e.g.
the cut algorithm, also in parallel with the read/decompress process. This would be 
part of a larger optimisation project which is beyond the scope of this document.

This threading will be most efficient if reading and decompression take approximately 
the same time, and benchmarking should ascertain if it is so.

Alex proposes that the threading only be done in mex-C++, with the parent Matlab code 
strictly sequential. Consequently any the choice of any threading method in Matlab is
not specified. 

In C++ there are now native threads.

### Caching of vector intermediates in calculate_qw_pixels2

The recruitment of the calculate_qw_pixels2 method for the decompression raises the 
issue of recalculation of detector vector properties, i.e. the scattering and final 
wavevectors.
The detector bank stores the detector orientation as angles (polar, azimuthal) and 
conversion to unit vectors requires evaluation of their trigonometric functions,
possibly multiple times.
The cost of these conversions can be reduced by caching their results up front before 
the read/decompression cycle commences.

Refactoring in this way requires
   - rewriting caculate_qw_pixels2 to use the cached values
   - an initialiser object before all decompressions to evaluate and store the cached values.
\[NB the actual cached quantities are not identified at this point].
This need for initialisation and storage suggests (as per Alex' suggestion) ntroduction
of a specific pixel faccess object factored out from the main faccess object. This
object could also manage the threading described above.

The resulting pixel faccess object can then be be factored out from faccess_sqw_v4 
providing an alternative way of relating the v4 and v5 faccess objects.

The size of the cache could be large - the detector information is effectively
duplicated, although changed in representation. The memory penalty for this should be
ascertained.

