% The folder contains main code responsible for storing Horace
% sqw and dnd objects on hdd and restoring them back into memory.
% The code comprises of number of various classes and functions, namely
%
% Main access point:
% sqw_formats_factory - signleton class which registers all existing file
%                       formats supported by Horace and is responsible for
%                       providing appropriate accessor for reading sqw
%                       files from disk or writing sqw/dnd object back from
%                       memory
%
% File access interface description:
% dnd_file_interface - class describes main public methods, used to read/write
%                      dnd image information.
% sqw_file_interface - class describes main public methods, used to read/write
%                      all remaining information may be found in sqw files,
%                      particularly metadata describing each file
%                      contributing into the sqw file, instrument and
%                      sample information and finally information about
%                      contributing pixels.
%
% File access main code:
% dnd_binfile_common - class implements common part of dnd_file_interface
%                      and contains main code, used to read/write dnd image
%                      information stored in binary dnd/sqw files.
% sqw_binfile_common - class implements common part of sqw_file_interface
%                      and contains main code, used to read/write sqw part of
%                      the information stored in binary sqw files.
%
% The classes supporting particular file format access:
% faccess_dnd_v2     - class to read/write Horace dnd files written by Horace v1-v2
% faccess_sqw_prototype - class to read legacy Horace sqw files written
%                         before 2008. It is currently impossible to write
%                         sqw files using this format so user should
%                         upgrate such files to new file format. 
% faccess_sqw_v2    - class to read/write sqw Horace files written by 
%                     Horace v1-v2 (2008-2016). Also reads and converts 
%                     levacy v3.0 file format.
% faccess_sqw_v2    - class to read/write sqw Horace files version 3.1. 
%                     The format stores the description of all Horace sqw 
%                     fields at the end of a binary file and nay contain 
%                     instrument and sample information. This is the format
%                     by default used by Horace v3.1 (released in the 
%                     beginning of 2017).
%
% Auxiliary classes and folders:
% sqw_serializer  - the class to serialize/deserialize (convert to/from
%                   sequence of bytes) various Matlab structures including 
%                   parts of sqw class and estimate the byte-size of these
%                   structures on disk and in memory. Uses classes from 
%                   sqw_fields_formatters folder to help with
%                   serialization. 
% const_blocks_map - class to support the map of the constant blocks in
%                    sqw/dnd file, used to modify partial binary information
%                    within the sqw file.
% sqw_fields_formatters -  contains classes describing how bytes of various 
%                    sqw object components are written on hdd and
%                     how to serialize/deserialize these components.
% class_helpers    - contains various small classes and functions
%                    used by the classes, present in this folder. 
%