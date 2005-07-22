function data = get_grid_data (fid, ndim, data_in)
%  Read the grid data from a binary file created by slice_4d, slice_3d or writegrid.
%
% Syntax:
%   >> data = get_grid_data (fid, ndim)             % read to new data structure
%   >> data = get_grid_data (fid, ndim, data_in)    % append to existing data structure
%
% Input:
% ------
%   fid         File pointer to (already open) binary file
%   ndim        Dimension of data arrays to read
%   data_in     (Optional) data structure to which the grid data fields below will be added
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

% Check input arguments:
if nargin<2; error ('ERROR: Check number of arguments to get_grid_data'); end
if nargin>=2 && ~isa_size(ndim,[1,1],'numeric'); error('ERROR: Check input argument ''ndim'' is numeric'); end
if nargin==3 && ~isstruct(data_in); error ('ERROR: Check input argument ''data_in'' is a structure'); end

% Transfer the input data structure, if present:
if nargin==3
    data = data_in;
end

% Read data
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
    data.n = zeros(np1-1,np2-1,np3-1,np4-1,'int16');
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
    ntot = np1-1;
    data.s = zeros(np1-1);
    data.e = zeros(np1-1);
    data.n = zeros(np1-1);
    [data.s,count] = fread(fid,ntot,'float32');
    data.s = reshape(data.s,1,np1-1);
    [data.e,count] = fread(fid,ntot,'float32');
    data.e = reshape(data.e,1,np1-1);
    [data.n,count] = fread(fid,ntot,'double');
    data.n = double(reshape(data.n,1,np1-1));
elseif ndim==0
    [data.s,count] = fread(fid,1,'float32');
    [data.e,count] = fread(fid,1,'float32');
    [data.n,count] = fread(fid,1,'double');
else
    error('Error: Check dimension of dataset');
end