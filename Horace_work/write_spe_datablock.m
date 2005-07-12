function write_spe_datablock (fid, data)
% Writes a block of .spe data to a binary file. Inverse of get_spe_datablock
%
% NOTE:
%  if change format of spe datablock in get_spe_datablock and write_spe_datablock,
%  also change gen_hkle which effectively incorporates a customised version of 
%  write_spe_datablock.
%
% Input:
% ------
%   fid     File pointer to (already open) binary file
%
%   data    Data structure with the following fields:
%
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
%   data.ERR    Variance vector [row vector]
%

% Original author: J. van Duijn
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring

fwrite(fid, data.ei, 'float32'); 
fwrite(fid, data.psi, 'float32');
fwrite(fid, data.cu, 'float32');
fwrite(fid, data.cv, 'float32');
n=length(data.file);
fwrite(fid, n, 'int32');
fwrite(fid, data.file, 'char');
fwrite(fid, data.size, 'int32');
nt= size(1)*size(2);
fwrite(fid, reshape(data.v, nt, 3)', 'float32');
fwrite(fid, data.en, 'float32');
fwrite(fid, reshape(data.S, 1, nt), 'float32');
fwrite(fid, reshape(data.ERR, 1, nt), 'float32');
