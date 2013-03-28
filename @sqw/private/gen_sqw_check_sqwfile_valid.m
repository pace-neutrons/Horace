function [ok,mess,header,detpar,grid_size,urange]=gen_sqw_check_sqwfile_valid(sqw_file)
% Check that the sqw file has the correct attributes to which to accumulate, and return useful information
%
%   >> [ok,mess,grid_size,urange]=gen_sqw_check_sqwfile_valid(sqw_file)
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
%   urange      Actual limits of the grid (NOT the data)
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
[sqw_type, ndims, filename, mess] = is_sqw_type_file(sqw,sqw_file);
if ~isempty(mess)
    ok=false;
    header={}; detpar=[]; grid_size=[]; urange=[];
    return
end
if ~sqw_type || ndims~=4
    ok=false;
    mess='The file to which to accumulate does not hold sqw data, or does not have 4 dimensions';
    header={}; detpar=[]; grid_size=[]; urange=[];
    return
end    

% Get header information to check other fields
% --------------------------------------------
[main_header,header,detpar,data,mess,position,npixtot]=get_sqw (sqw_file,'-h');
header_ave=header_average(header);

tol=2e-7;    % test number to define equality allowing for rounding errors (recall fields were saved only as float32)
ok =equal_to_relerr(header_ave.alatt, data.alatt, tol, 1) &...
    equal_to_relerr(header_ave.angdeg, data.angdeg, tol, 1) &...
    equal_to_relerr(header_ave.uoffset, data.uoffset, tol, 1) &...
    equal_to_relerr(header_ave.u_to_rlu(:), data.u_to_rlu(:), tol, 1) &...
    equal_to_relerr(header_ave.ulen, data.ulen, tol, 1);
if ~ok
    ok=false;
    mess='The sqw to which to accumulate does not have the correct projection axes for this operation.';
    header={}; detpar=[]; grid_size=[]; urange=[];
    return
end

grid_size=zeros(1,4);
for i=1:4
    grid_size(i)=numel(data.p{i})-1;
end
urange=[data.p{1}(1) data.p{2}(1) data.p{3}(1) data.p{4}(1); ...
        data.p{1}(end) data.p{2}(end) data.p{3}(end) data.p{4}(end)];
    