function sqw_display_single(din,npixtot,nfiles,type)
% Display useful information from an sqw object
%
% Syntax:
%
%   >> sqw_display_single (din)
%   >> sqw_display_single (din,npixtot,nfiles,type)
%
%   din             Structure from sqw object (sqw-type or dnd-type)
%
% Optionally:
%   npixtot         total number of pixels if sqw type
%   nfiles          number of contributing files
%   type            data type: 'a' or 'b+'
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


% NOTE: use sprintf to get fixed formatting of numbers (num2str strips trailing blanks)

% Determine if displaying dnd-type or sqw-type sqw object


ndim = din.dimensions;
if ~exist('npixtot','var') || isempty(npixtot)
    npixtot = sum(din.data.npix(:));
end

if ~exist('type','var') || isempty(type)
    if isempty(din.pix)
        type = 'b+';        
    else
        type = 'a';
    end
end

if isa(din,'sqw') || isfield(din,'main_header')
    sqw_type=true;  % object will be dnd type
    nfiles = din.main_header.nfiles;
else
    sqw_type=false;
end

% Display summary information
disp(' ')
disp([' ',num2str(ndim),'-dimensional object:'])
disp(' -------------------------')
if isa(din,'sqw')
    din = din.data;
end


if ~isempty(din.filename)
    filename=fullfile(din.filepath,din.filename);
    disp([' Original datafile: ',filename])
else
    disp([' Original datafile: ','<none>'])
end


if ~isempty(din.title)
    disp(['             Title: ',din.title])
else
    disp(['             Title: ','<none>'])
end


disp(' ')
disp( ' Lattice parameters (Angstroms and degrees):')
disp(['         a=',sprintf('%-11.4g',din.alatt(1)),    '    b=',sprintf('%-11.4g',din.alatt(2)),   '     c=',sprintf('%-11.4g',din.alatt(3))])
disp(['     alpha=',sprintf('%-11.4g',din.angdeg(1)),' beta=',sprintf('%-11.4g',din.angdeg(2)),' gamma=',sprintf('%-11.4g',din.angdeg(3))])
disp(' ')


if sqw_type || exist('nfiles','var') && isnumeric(nfiles)
    disp( ' Extent of data: ')
    disp(['     Number of spe files: ',num2str(nfiles)])
    disp(['        Number of pixels: ',num2str(npixtot)])
    disp(' ')
end

[title_main, title_pax, title_iax, display_pax, display_iax] = data_plot_titles (din);
if ndim~=0
    sz = din.nbins;
    npchar = '[';
    for i=1:ndim
        npchar = [npchar,num2str(sz(din.dax(i))),'x'];   % size along each of the display axes
    end
    npchar(end)=']';
    disp([' Size of ',num2str(ndim),'-dimensional dataset: ',npchar])
end
if ndim~=0
    disp( '     Plot axes:')
    for i=1:ndim
        disp(['         ',display_pax{i}])
    end
    disp(' ')
end
if ndim~=4
    disp( '     Integration axes:')
    for i=1:4-ndim
        disp(['         ',display_iax{i}])
    end
    disp(' ')
end

% Print warning if no data in the cut, if full cut has been passed
if npixtot < 0.5   % in case so huge that can no longer hold integer with full precision
    fprintf(2,' WARNING: The dataset contains no counts\n')
end

