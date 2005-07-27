function data = get_grid_data (fid, data_in)
%  Read the grid data from a binary file created by slice_4d, slice_3d
% or writegrid.
%
% Syntax:
%   >> data = get_grid_data (fid, data_in)
%
% Input:
% ------
%   fid         File pointer to (already open) binary file
%   data_in     Header data structure to which the grid data fields below will be added
%              *OR* dimension of data grid to be read into a fresh structure
%
% Output:
% -------
%   data.p1    Column vector of bin boundaries along first plot axis
%   data.p2    Column vector of bin boundaries along second plot axis
%     :       (for as many plot axes as given by ndim)
%   data.s     Cumulative signal.  [size(data.s)=(length(data.p1)-1, length(data.p2)-1, ...)]
%   data.e     Cumulative variance [size(data.e)=(length(data.p1)-1, length(data.p2)-1, ...)]
%   data.n     Number of contributing pixels [size(data.n)=(length(data.p1)-1, length(data.p2)-1, ...)]
%             (if ndim=1,2 or 3, then data.n is double; if n=4 then data.n is int16)

% Original author: J. van Duijn
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring

if ~isstruct(data_in) 
    ndim = data_in;
elseif isstruct(data_in) && isfield(data_in,'pax');
    data = data_in;
    ndim = length(data_in.pax);
else
    error ('ERROR: Check the type of input argument data_in')
end

if ndim==4
    [np1,count] = fread(fid,1,'int32');
    [np2,count] = fread(fid,1,'int32');
    [np3,count] = fread(fid,1,'int32');
    [np4,count] = fread(fid,1,'int32');
    [data.p1,count] = fread(fid,np1,'float32');
    [data.p2,count] = fread(fid,np2,'float32');
    [data.p3,count] = fread(fid,np3,'float32');
    [data.p4,count] = fread(fid,np4,'float32');
    ntot = (np1-1)*(np2-1)*(np3-1)*(np4-1);
    data.s = zeros(np1-1,np2-1,np3-1,np4-1);
    data.e = zeros(np1-1,np2-1,np3-1,np4-1);
    data.n = int16(data.s);
    [data.s,count] = fread(fid,ntot,'float32');
    data.s = reshape(data.s,np1-1,np2-1,np3-1,np4-1);
    [data.e,count] = fread(fid,ntot,'float32');
    data.e= reshape(data.e,np1-1,np2-1,np3-1,np4-1);
    [data.n,count] = fread(fid,ntot,'int16');
    data.n = int16(reshape(data.n,np1-1,np2-1,np3-1,np4-1));
elseif ndim==3
    [np1,count] = fread(fid,1,'int32');
    [np2,count] = fread(fid,1,'int32');
    [np3,count] = fread(fid,1,'int32');
    [data.p1,count] = fread(fid,np1,'float32');
    [data.p2,count] = fread(fid,np2,'float32');
    [data.p3,count] = fread(fid,np3,'float32');
    ntot = (np1-1)*(np2-1)*(np3-1);
    data.s = zeros(np1-1,np2-1,np3-1);
    data.e = zeros(np1-1,np2-1,np3-1);
    data.n = zeros(np1-1,np2-1,np3-1);
    [data.s,count] = fread(fid,ntot,'float32');
    data.s = reshape(data.s,np1-1,np2-1,np3-1);
    [data.e,count] = fread(fid,ntot,'float32');
    data.e = reshape(data.e,np1-1,np2-1,np3-1);
    [data.n,count] = fread(fid,ntot,'double');
    data.n= double(reshape(data.n,np1-1,np2-1,np3-1));
elseif ndim==2
    [np1,count] = fread(fid,1,'int32');
    [np2,count] = fread(fid,1,'int32');
    [data.p1,count] = fread(fid,np1,'float32');
    [data.p2,count] = fread(fid,np2,'float32');
    ntot = (np1-1)*(np2-1);
    data.s = zeros(np1-1,np2-1);
    data.e = zeros(np1-1,np2-1);
    data.n = zeros(np1-1,np2-1);
    [data.s,count] = fread(fid,ntot,'float32');
    data.s= reshape(data.s,np1-1,np2-1);
    [data.e,count] = fread(fid,ntot,'float32');
    data.e= reshape(data.e,np1-1,np2-1);
    [data.n,count] = fread(fid,ntot,'double');
    data.n = double(reshape(data.n,np1-1,np2-1));
elseif ndim==1
    [np1,count] = fread(fid,1,'int32');
    [data.p1,count] = fread(fid,np1,'float32');
    ntot = data.np1-1;
    data.s = zeros(np1-1);
    data.e = zeros(np1-1);
    data.n = zeros(np1-1);
    [data.s,count] = fread(fid,ntot,'float32');
    data.s = reshape(data.s,np1-1);
    [data.e,count] = fread(fid,ntot,'float32');
    data.e = reshape(data.e,np1-1);
    [data.n,count] = fread(fid,ntot,'double');
    data.n = double(reshape(data.n,np1-1));
elseif ndim==0
    [data.s,count] = fread(fid,1,'float32');
    [data.e,count] = fread(fid,1,'float32');
    [data.n,count] = fread(fid,1,'double');
else
    error('Error: Check dimension of dataset');
end