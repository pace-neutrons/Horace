Design of faccess_sqw which includes compression of pixel data
==============================================================

See ADD-11 
[sqw-compression](https://github.com/pace-neutrons/Horace/blob/master/documentation/add/11_sqw_compression.md)
for previous planning.

Goal:
-----

The aim is to write/read pixel data to/from file so that
   - (qx,qy,qz,E) data is not written out
   - (irun,idet,ien) indexing is used to calculate (qx,qy,qz,E) when the data 
is read.
   - (irun,idet,ien) is written in compressed form as a single integer
irun + nrun*( idet-1 + ndet*(ien-1)). If not already stored, then the index maxima
(nrun,ndet,nen) should also be stored.

faccess class
-------------

A new faccess class `faccess_sqw_v5` will be created based on the current supported
class `faccess_sqw_v4`. On read, the stored data will determine this class for
files created by the revised code; files created earlier will use whatever accessor
was used to create them. 

On write the class will be determined by the default class for `sqw` objects
produced by the `sqw_formats_factory` in `horace_core\sqw\file_io`. Its variable 
`supported_accessors_` currently provides `faccessor_sqw_v4` for type `1` variables.
Its variable `written_types_` specifies `sqw` as the second written type and 
`access_to_type_ind_` gives the index of that type as `1`. Hence `supported_accessors_(1)`
should be reset to `faccessor_sqw_v5`. This will also make this the correct save type for
type `sqw2` and care should be taken that further changes to read/write access via
this new accessor should not compromise uses with `sqw2`.

Note that other object types (`DnDBase`,`dn/0/1/2/3/4d`) read/write from/to type 2
which is `faccess_dnd_v4`, and as these dnd-type objects do not contain pixel 
information it is not expected that these object types will need their accessor
type changing. Earlier supported accessor types are listed in the `supported_accessors_`
list but are not referenced in the `access_to_type_ind_` list and it is assumed that
the codebase no longer supports them as default types, only as types stored in
existing files of earlier format.

The default preferred accessor type `preferred_accessor_num_` is set to `1` and hence
will be automatically upgraded by the above changes.


Method for retrieving (qx,qy,qz,E) from the saved file
------------------------------------------------------

The calculation of (qx,qy,qz,E) on read is done with the existing function
`calculate_qw_pixels2`. For this to work, the experiment information must be present.
The sqw object being saved is, if present, stored in the faccess object in the
variable `sqw_holder`. If this is present, the compression can be done. If not, the
pixels must be stored uncompressed. It is presumed that on read, the sqw_holder 
variable will either be populated or not populated before the pixels are read; if populated, 
it is assumed that the pixels have been compressed, and otherwise not.





