% The folder contains main code responsible for storing Horace
% sqw and dnd objects on hdd and restoring them back into memory.
% The code comprises of number of various classes and functions, namely:
%
%
% $Revision:: 1751 ($Date:: 2019-06-03 09:47:49 +0100 (Mon, 3 Jun 2019) $)
%

% Main sqw-files access class:
% sqw_formats_factory - singleton class which registers all existing file
%                       formats supported by Horace and is responsible for
%                       providing appropriate accessor for reading sqw
%                       files from disk or writing sqw/dnd objects stored
%                       in memory.
%
% File access interface description:
% dnd_file_interface - class describes main public methods, used to read/write
%                      dnd image information.
% sqw_file_interface - class describes main public methods, used to read/write
%                      all remaining (non-dnd) information found in sqw files,
%                      particularly metadata describing each file
%                      contributing into the sqw file, instrument and
%                      sample information and finally information about
%                      the contributing pixels.
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
%                         upgrade such files to new file format.
% faccess_sqw_v2    - class to read/write sqw Horace files written by
%                     Horace v1-v2 (2008-2016). Also reads and converts
%                     legacy v3.0 file format.
% faccess_sqw_v3    - class to read/write sqw Horace files version 3.1.
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
%                   structures on disk and in memory. Used by the file access
%                   classes above to organize binary data exchange with storage
%                   and uses the classes from sqw_fields_formatters folder
%                   to help with serialization.
% const_blocks_map - class to support the map of the constant blocks in
%                    sqw/dnd file, used to modify partial binary information
%                    within an sqw file.
% sqw_fields_formatters -  contains classes implementing byte-representation
%                     of various sqw object components and procedures
%                     to serialize/deserialize these components.
% class_helpers    - contains various small classes and functions
%                    used by the main classes responsible for file-io
%                    operations and located in the file_io folder.
%
% The inheritance/collaboration diagram for main classes, used to support
% file_io operations can be viewed <a href="matlab:imshow('CollabDiagram.png');">here.</a>
%
% Normal practice to organize organize access to sqw files can be as follows:
% -------------------------------------------------------------------------
%1) To read existing sqw file or its parts:
% the below returns a faccess_sqw/faccess_dnd loader suitable for accessing
% sqw file with filename provided.
%>>accessor = sqw_formats_factory.instance().get_loader(filename);
% Read all sqw data:
%>>sqw_object = accessor.get_sqw();
% To read partial sqw data one can use any get methods from
% sqw_file_interface or dnd_file_interface.
%
% To reopen this file to modify all sqw data or its parts one should
% execute:
%>>new_accessor = accessor.upgrade_file_format()
% which will upgrade sqw file format to a recent version and reopen file
% for modification of the parts, which can be modified..
%
% -------------------------------------------------------------------------
%2) To write new sqw sqw file or modify some of its parts:
% one should execute the following commands:
%>>accessor = sqw_formats_factory.instance().get_pref_access(); % if one
%             needs recent sqw file format writer or
%>>accessor = sqw_formats_factory.instance().get_pref_access(obj_to_write)
%            if obj_to_write is dnd object or sqw object with some special
%            properties.
% The recommended accessor should be initialized by the object to write:
%>>accessor = accessor.init(obj_to_write,filename);
% If the file with "filename" exists, it will be opened for upgrade if such
% upgrade is possible. If not, the file will be overwritten.
% Then one can write the whole data:
%>>accessor = accessor.put_sqw();
% or any part of the data, using correspondent put methods of
% sqw_file_interface or dnd_file_interface. If file is open for upgrade, 
% accessor = accessor.put_sqw() command does not modify the class pixels.
% Separate put_pix command should be used to do this if requested.
%
% See the whole list of methods to use for exchanging information with sqw
% files in the classes to access these files and common sqw/dnd file
% interface.
% -------------------------------------------------------------------------
%Known problem||inconsistencies:
% Options in accessors/mutators are not always consistent, e.g. a get_sqw
% method of faccess_dnd_v2 class may not accept all options get_sqw of
% faccess_sqw_v2 class accepts.
% Proper solution would be to get rid of all options which are not the same
% through the interface, and writing separate methods providing missing
% functionality, but it contradicts the previous implementation, so is a major
% task.