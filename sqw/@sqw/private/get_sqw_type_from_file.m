function [mess, sqw_type, ndims, nfiles] = get_sqw_type_from_file(infile)
% Get sqw_type and dimensionality of an sqw file on disk
%
%   >> [mess, sqw_type, ndims, nfiles] = get_sqw_type_from_file (infile)
%
% Input:
% --------
%   infile      File name
%
% Output:
% --------
%   mess        Error message; blank if no errors, non-blank otherwise
%   sqw_type    =true  if sqw-type contents; =false if dnd-type contents
%   ndims       Number of dimensions
%   nfiles      Number of contributing spe data sets (=0 if not sqw-type)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
try
    ld = sqw_formats_factory.instance().get_loader(infile);
    sqw_type = ld.sqw_type;
    ndims = ld.num_dim;
    if sqw_type
        nfiles = ld.num_contrib_files;
    else
        nfiles = 0;
    end
    mess = [];
catch ME
    mess = ME.msgtext;
    return
end
