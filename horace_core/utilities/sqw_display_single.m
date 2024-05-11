function sqw_display_single(din,npixtot,nfiles,filebacked)
% Display useful information from an sqw object
%
% Syntax:
%
%   >> sqw_display_single (din)
%   >> sqw_display_single (din,npixtot,nfiles,type)
%
%   din             Structure from sqw object (sqw-type or dnd-type) or
%                   this obect itself
%
% Optionally:
%   npixtot         total number of pixels if sqw type
%   nfiles          number of contributing files
%   filebacked      if true, object obtained from file. This changes the way,
%                   information is displayed
%
%   If the optional parameters are given, then only the header information
%   part of data needs to be passed, namely the fields:
%      uoffset,u_to_rlu,ulen,ulabel,iax,iint,pax,p,dax[,pix_range]
%  (pix_range is only present if sqw type object)
%
%   If the optional parameters are not given, then the whole data structure
%   needs to be given, and npixtot and type are computed from the structure.
%
%   If an optional parameter is given but is empty, then the missing value for that
%   parameter is computed from the data structure.
%

% Original author: T.G.Perring
%

% Determine if displaying dnd-type or sqw-type sqw object

ndim = din.dimensions;

if isa(din,'sqw') || isfield(din,'main_header')
    sqw_type=true;  % object will be dnd type
    nfiles = din.main_header.nfiles;
else
    sqw_type=false;
end

if ~exist('npixtot','var') || isempty(npixtot)
    if sqw_type
        npixtot = sum(din.data.npix(:));
    else
        npixtot = sum(din.npix(:));
    end
end

%
if nargin<4
    filebacked = false;
end

% Display summary information
disp(' ')
fprintf('\n  %d-dimensional object:\n',ndim);
fprintf(' -------------------------\n');
if isa(din,'sqw')
    is_filebacked = din.pix.is_filebacked;
    din = din.data;
else
    is_filebacked  = [];
end


if ~isempty(din.filename)
    filename=fullfile(din.filepath,din.filename);
    fprintf(' Original datafile:  %s\n',filename)
else
    fprintf(' Original datafile:  <none>\n')
end

if ~isempty(din.title)
    fprintf('             Title: %s',din.title)
else
    fprintf('             Title: <none>')
end
fprintf('\n\n')
fprintf(' Lattice parameters (Angstroms and degrees):\n')
fprintf('     a=%-11.4g    b=%-11.4g     c=%-11.4g\n',din.alatt)
fprintf(' alpha=%-11.4g beta=%-11.4g gamma=%-11.4g\n\n',din.angdeg)


if sqw_type || exist('nfiles','var') && isnumeric(nfiles)
    fprintf(' Extent of data:\n')
    fprintf(' Number of spe files: %d\n',nfiles)
    fprintf('    Number of pixels: %d\n\n',npixtot)
end

[~, ~, ~, display_pax, display_iax] = din.data_plot_titles;
if ndim~=0
    sz = din.nbins;
    if ~isempty(sz)
        dims = sz(din.dax);
        npchar = sprintf('[%dx%dx%dx%dx',dims);
        npchar(end)=']';
    else
        npchar = '[ ]';
    end
    fprintf(' Size of %d-dimensional dataset: %s\n',ndim,npchar)
end
if ndim~=0
    fprintf( '     Plot axes:\n');
    for i=1:ndim
        fprintf('          %s\n',display_pax{i});
    end
end
if ndim~=4
    fprintf('     Integration axes:\n');
    for i=1:4-ndim
        fprintf('          %s\n',display_iax{i});
    end
end
if  ~isempty(is_filebacked)
    if is_filebacked
        pixels_location = 'filebacked';
    else
        pixels_location = 'memory based';
    end
    fprintf(' Object is: %s\n',pixels_location);
end
% Print warning if no data in the cut, if full cut has been passed
if npixtot < 0.5   % in case so huge that can no longer hold integer with full precision
    fprintf(2,' WARNING: The dataset contains no counts\n')
end
if ~filebacked
    fprintf('\n');
end

