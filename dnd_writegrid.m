function dnd_writegrid (data, binfil)
% Writes 1D, 2D, 3D, or 4D dataset to a binary file.
%
% Syntax:
%   >> dnd_writegrid (data, binfil)
%
% Input:
% ------
%   data    1D, 2D, 3D or 4D Dataset. 
%          Type 
%               >> help dnd_checkfields 
%           for a full description of the fields of these data structures
%
%   binfil  Name of file to which the data will be written.

% Original author: J. van Duijn
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring


% Get file name - prompting if necessary
% --------------------------------------
if (nargin==1)
    file_internal = putfile;
    if (isempty(file_internal))
        error ('No file given')
    end
elseif (nargin==2)
    file_internal = binfil;
end

fid = fopen (file_internal, 'w');
if (fid < 0)
    error (['ERROR: cannot open file ' file_internal])
end

% Open file
disp('Writing binary file ...')

% Write header information
write_header(fid,data);

% Write grid information and the data itself:
ndim = length(data.pax);
write_grid_data(fid,ndim,data);

fclose(fid);