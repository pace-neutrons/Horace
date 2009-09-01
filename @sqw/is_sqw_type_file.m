function [sqw_type, nd, data_source, mess] = is_sqw_type_file(sqw, infile)
% Determine if file contains data of an sqw-type object or dnd-type sqw object
% 
%   >> [sqw_type, nd, data_source, mess] = is_sqw_type_file(sqw, infile)
%
%   sqw is a dummy sqw object used to enforce a call to this method
%   data_source


% Original author: T.G.Perring
%
% $Revision: 259 $ ($Date: 2009-08-18 13:03:04 +0100 (Tue, 18 Aug 2009) $)


% Simply an interface to private function that we wish to keep hidden
[sqw_type, nd, mess] = get_sqw_type_from_file (infile);

% Wrap file name in a structure with a key to identify the file as being the input sqw data
data_source.keyword='$file_data';
data_source.file=infile;
data_source.sqw_type=sqw_type;
data_source.ndims=nd;
