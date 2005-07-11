function write_grid_data (fid, data)
% Writes a block of .spe data to a binary file
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
%              Note: size(data.v) = [no. dets * no. energy bins, 3]
%   data.en     Vector containing the energy bin centres [row vector]
%   data.S      Intensity vector
%   data.ERR    Error vector
%

% Original author: J. van Duijn
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring

fwrite(fid, data.efixed, 'float32'); 
fwrite(fid, psi(i), 'float32');
fwrite(fid, data.uv(1,:), 'float32');
fwrite(fid, data.uv(2,:), 'float32');
n=length(data.filename);
fwrite(fid, n, 'int32');
fwrite(fid, data.filename, 'char');
sized= size(data.v);
fwrite(fid,sized(1:2),'int32');
% Reshape and transpose the data.v array so that it becomes data.v(1:3,:) where each
% column corresponds to components along u1, u2, u3 for one pixel.
% Do the corresponding reshape and transpose for the signal and error arrays.
nt= sized(1)*sized(2);
fwrite(fid,reshape(data.v, nt, 3)','float32');
fwrite(fid,data.en,'float32');
fwrite(fid,reshape(data.S, nt, 1)','float32');
fwrite(fid,reshape(data.ERR, nt, 1)','float32');
