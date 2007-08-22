function header (binfil)
% Displays header information in binary file containing
%   - binary spe or binary sqe file, or
%   - zero, one, two, three or four dimensional dataset.
%
% Also accepts a structure if it has the fields corresponding to a 0,1,2,3,4
% dimensional dataset.
%
% Syntax:
%   >> header (binfil)
%
% Input:
% -------
%   binfil  Binary data file
%
%

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring

% Catch case of being a structure with fields of a dataset object
if nargin>0
    if isstruct(binfil)
        [nd, mess] = dnd_checkfields (binfil);
        if ~isempty(nd)
            dnd_display(binfil);
            return
        else
            error('Structure does not have fields of a 0,1,2,3,4 dimensional dataset')
        end
    end
end

% Catch all other cases
if nargin>0
    if isa_size(binfil,'row','char')
        if (exist(binfil,'file')==2)
            file_internal = binfil;
        else
            file_internal = getfile(binfil);
        end
    else
        file_internal = getfile;
    end
else
    file_internal =  getfile;
end
if (isempty(file_internal))
    error ('No file given')
end

% Open binary file:
fid = fopen(file_internal,'r');
if fid<0
    error (['ERROR: Unable to open file ',file_internal])
end

% Read header information
data.file = file_internal;
[data, n, mess] = get_header(fid, data);
if ~isempty(mess); fclose(fid); error(mess); end

if isfield(data,'grid')
    if strcmp(data.grid,'spe') || strcmp(data.grid,'sqe')
        fclose(fid);
        display_header(data);
    elseif strcmp(data.grid,'orthogonal-grid')
        ndim = length(data.pax);
        [data, mess] = get_grid_data(fid, ndim, data, 'axes_only');
        if ~isempty(mess); fclose(fid); error(mess); end
        fclose(fid);
        display_header(data);
    else
        fclose(fid);
        error ('ERROR: The function header only reads binary spe, binary sqe or orthogonal grid data ');
    end
else
    fclose(fid);
    error ('ERROR: The function header only reads binary spe, binary sqe or orthogonal grid data ');
end
