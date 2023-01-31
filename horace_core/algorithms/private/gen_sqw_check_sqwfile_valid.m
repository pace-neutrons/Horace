function [ok,mess,header,grid_size,img_db_range,pix_range]=gen_sqw_check_sqwfile_valid(sqw_file)
% Check that the sqw file has the correct attributes to which to accumulate, and return useful information
%
%   >> [ok,mess,grid_size,img_db_range]=gen_sqw_check_sqwfile_valid(sqw_file)
%
% Input:
% ------
%   sqw_file    Filename containing sqw data.
%
% Output:
% -------
%   ok          True of all OK, false otherwise
%   mess        Error message if not OK; ='' if OK
%   header      Header from the sqw data
%   grid_size   Grid size [1,4] vector of number of bins along each axis
%   img_db_range Actual limits of the pixels, where pixels are rebinned into
%                (NOT the data)
%
%
% For the file to be valid for accumulation, we require:
%   - the data is sqw-type
%   - the sqw file is 4D
%   - the projection axes are crystal Cartesian coordinates
%
% The tests here are not foolproof, as the user can always have set individual fields,
% at will, but it should catch common errors e.g. passing a dnd file, or an sqw file
% created using the cut function so that the projection axes are no longer the same as
% pixel projection axes.


% Determine if the file contains sqw data, and dimensionality
% -----------------------------------------------------------
% (Note: as of 19 Mar 2013, this involves an implicit read of header if prototype sqw file format)
try
    ldr = sqw_formats_factory.instance().get_loader(sqw_file);
    sqw_type = ldr.sqw_type;
    ndims = ldr.num_dim;
    mess = [];
catch ME
    mess = ME.message;
end
if ~isempty(mess)
    ok=false;
    header={}; grid_size=[]; img_db_range=[];
    return
end
if ~sqw_type || ndims~=4
    ok=false;
    mess='The file to which to accumulate does not hold sqw data, or does not have 4 dimensions';
    header={};  grid_size=[]; img_db_range=[];
    return
end

% Get header information to check other fields
% --------------------------------------------
header = ldr.get_exp_info('-all');
data   = ldr.get_data('-head');
%[mess,main_header,header,detpar,data]=get_sqw (sqw_file,'-h');
header_ave=header.header_average();

tol=2e-7;    % test number to define equality allowing for rounding errors (recall fields were saved only as float32)
% TGP (15/5/2015) I am not sure if this is necessary: both the header and data sections are saved as float32, so
% should be rounded identically.
ok =equal_to_relerr(header_ave.alatt, data.alatt, tol, 1) &...
    equal_to_relerr(header_ave.angdeg, data.angdeg, tol, 1) &...
    equal_to_relerr(header_ave.offset, data.offset, tol, 1) &...
    equal_to_relerr(header_ave.u_to_rlu(:), data.u_to_rlu(:), tol, 1) &...
    equal_to_relerr(header_ave.ulen, data.ulen, tol, 1);
if ~ok
    ok=false;
    mess='The sqw to which to accumulate does not have the correct projection axes for this operation.';
    header={}; grid_size=[]; img_db_range=[];
    return
end

grid_size =data.nbins_all_dims;

img_db_range=data.img_range;
pix_range = ldr.get_pix_range();

