# Proposal for how to implement SQW compression

In the adjacent `add` document `11_sqw-compression, the rationale for compressing 
pixel data in SQW objects when writing them to file is given. Here a methodology for how
to implement that compression is given.

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

A method on the sqw class nindex = compress_pixels(win,[qx,qy,qz,E,irun,idet,ien],ibegin,iend)
where win is the containing sqw object for the pixels, will perform the above compression.
win provides the parameters nrun, ndet and nen. ibegin and iend are the first and last pixel
indices to be compressed by this call; the reason for including this is given below.

A method on the sqw class [qx,qy,qz,E,irun,idet,ien,ibegin,iend] = decompress_pixels(win,nindex)
where win is the containing sqw object for the pixels, will perform the above decompression.
win provides the parameters nrun, ndet, nen and the method for calculating the 
wave-vector and energy, which is `calculate_qw_pixels2`. ibegin and iend are extracted 
in an additional step of the data decompression.

These methods are called within the faccess class instance reading or writing the files. 
This class will be a new class faccess_sqw_v5 (the current one is faccess_sqw_v4)
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

These locations are the locations where the pixel data is written; it appears that there
is only one such location.

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
locations.

`get_pix_` is the method in horace_core\sqw\file_io\@faccess_sqw_v4\put_pix.m. It is
called from get_raw_pix. Note that another method `get_pix` exists as an alternative
caller of `get_pix_` but it appears only to be used for testing. This performs is single
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
New files created will be written as v5 and subsequently read by them as they identify as v5. To make v5 the default accessor for new files, `horace_core\sqw\file_io\sqw_formats_factory` should be modified to add v5 to the list of supported accessors. This should then be used for files of type 1 (sqw and sqw2). Other file types are unaffected by the changes here, which are only due to pixel file storage - they are DnD types where there is only image data.

## Refactoring

For the get_pix_ and put_pix methods, these are within the faccess class and will
automatically updated to use v5 when called. The PixelDataFileBacked version however
uses memmapfile within the init_from_file_accessor_ method of the PixelData object, 
which transfers ownership of this specialisation outside the faccess class. While the 
present plan does not require using memmapfile, it will be good to have an option for 
using it within get_pix_. This can be experimented with once the basic implementation
with direct primary read is in place. At that point Alex' suggestion of a PixelData 
processing factory can be considered.

## Optimization

Alex points out that the pixel decompression process may be slow, negating the 
advantages of compression, and that it should be done in a separate thread.
