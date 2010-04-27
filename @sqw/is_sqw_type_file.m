function [sqw_type, nd, data_source, mess] = is_sqw_type_file(sqw, infile)
% Determine if file contains data of an sqw-type object or dnd-type sqw object
% 
%   >> [sqw_type, nd, data_source, mess] = is_sqw_type_file(sqw, infile)
%
%   sqw is a dummy sqw object used to enforce a call to this method
%   data_source


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Simply an interface to private function that we wish to keep hidden
if get(hdf_config,'use_hdf')
    data_file=sqw_hdf(infile,'-no_new');
    
    nd = numel(data_file.signal_dims);
    
    sqw_type= data_file.pixels_present;
    % closes the hdf 5 and its handles from memory rather then deleting the
    % file
    data_file.delete();
    mess='';
else
[sqw_type, nd, mess] = get_sqw_type_from_file (infile);
end

% Wrap file name in a structure with a key to identify the file as being the input sqw data
data_source.keyword='$file_data';
data_source.file=infile;
data_source.sqw_type=sqw_type;
data_source.ndims=nd;
