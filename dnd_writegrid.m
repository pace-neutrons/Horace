function dnd_writegrid (data, binfil)
% Writes 1D, 2D, 3D, or 4D dataset to a binary file.
%
% Syntax:
%   >> dnd_writegrid (data, binfil)
%
% Input:
% ------
%   data    1D, 2D, 3D or 4D Dataset. 
%          Type >> help dnd_checkfields for a full description of the fields of these data structures
%
%   binfil  Name of file to whicht he data will be written.

% Original author: J. van Duijn
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring

fid = fopen(binfil,'w');
disp('Writing binary file ...')

% Write header information
write_header(fid,data);

% Write grid information and the data itself:
ndim = length(data.pax);
write_grid_data(fid,ndim,data);

fclose(fid);