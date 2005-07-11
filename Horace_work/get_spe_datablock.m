function data = get_spe_datablock (fid, data_in)
%  Read the a block of data corresponding to one .spe file from a binary file created
% by gen_hkle.
%
% Input:
% ------
%   fid         File pointer to (already open) binary file
%   data_in     [optional] Header data structure to which the grid data
%              fields below will be added.
%
% Output:
% -------
%   data.ei     Incident energy used for spe file (meV)
%   data.psi    Psi angle (deg)
%   data.cu     u crystal axis (r.l.u.) (see mslice) [row vector]
%   data.cv     v crystal axis (r.l.u.) (see mslice) [row vector]
%   data.file   File name of .spe file corresponding to the block being read
%   data.size   size(1)=number of detectors; size(2)=number of energy bins [row vector]
%   data.v      Array containing the components along the mslice projection
%              axes u1, u2, u3 for each pixel in the .spe file.
%              Note: size(data.v) = [3, no. dets * no. energy bins]
%   data.en     Vector containing the energy bin centres [row vector]
%   data.S      Intensity vector [row vector]
%   data.ERR    Error vector [row vector]
%

% Original author: J. van Duijn
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring

if nargin==2
    if isstruct(data_in)
        data = data_in;
    else
        error ('ERROR: Check the type of input argument data_in')
    end
end

[data.ei,count]= fread(fid, 1, 'float32');
[data.psi,count]= fread(fid, 1, 'float32');
[data.cu,count]= fread(fid, [1,3], 'float32');
[data.cv,count]= fread(fid, [1,3], 'float32');
[n,count]=fread(fid, 1, 'int32');
[data.file,count]=fread(fid, [1,n], '*char');
[data.size,count]= fread(fid, [1,2], 'int32');
nt= data.size(1)*data.size(2);
[data.v,count]= fread(fid, [3,nt], 'float32');
[data.en,count]= fread(fid, [1,data.size(2)], 'float32');
[data.S,count]= fread(fid, [1,nt], 'float32');
[data.ERR,count]= fread(fid, [1,nt], 'float32');

