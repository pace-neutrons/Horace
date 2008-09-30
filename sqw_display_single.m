function sqw_display_single (main_header,header,detpar,data,npixtot,type)
% Display useful information from an sqw object
%
% Syntax:
%
%   >> sqw_display_single (main_header,header,detpar,data)
%   >> sqw_display_single (main_header,header,detpar,data,npixtot,type)
%
%   main_header -|
%   header       |- fields from sqw object
%   detpar       |
%   data        -|
%
% Optionally:
%   npixtot         total number of pixels if sqw type
%   type            data type: 'a' or 'b+'
%                   if this is not given, then it overrides any attempt
%                  
%   If the optional parameters are given, then only the header information
%   part of data needs to be passed, namely the fields:
%      uoffset,u_to_rlu,ulen,ulabel,iax,iint,pax,p,dax[,urange]
%  (urange is only present if sqw type object)
%
%   If the optional parameters are not given, then the whole data structure
%   needs to be given, and npixtot and type are computed from the structure

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)


% NOTE: use sprintf to get fixed formatting of numbers (num2str strips trailing blanks)

% Determine if displaying dnd-type or sqw-type sqw object


[ndim,sz] = sqw_data_dims(data);

if ~exist('npixtot','var')||~exist('type','var')
    type = sqw_data_type(data);
    if strcmpi(type,'a')
        npixtot = sum(data.npix(:));
    else
        npixtot=[];
    end
end

if strcmpi(type,'a')
    sqw_type=true;  % object will be dnd type
    nfiles = main_header.nfiles;
else
    sqw_type=false;
end

% Display summary information
disp(' ')
disp([' ',num2str(ndim),'-dimensional object:'])
disp(' -------------------------')


if ~isempty(data.filename)
    filename=fullfile(data.filepath,data.filename);
    disp([' Original datafile: ',filename])
else
    disp([' Original datafile: ','<none>'])
end


if ~isempty(data.title)
    disp(['             Title: ',data.title])
else
    disp(['             Title: ','<none>'])
end


disp(' ')
disp( ' Lattice parameters (Angstroms and degrees):')
disp(['         a=',sprintf('%-11.4g',data.alatt(1)),    '    b=',sprintf('%-11.4g',data.alatt(2)),   '     c=',sprintf('%-11.4g',data.alatt(3))])
disp(['     alpha=',sprintf('%-11.4g',data.angdeg(1)),' beta=',sprintf('%-11.4g',data.angdeg(2)),' gamma=',sprintf('%-11.4g',data.angdeg(3))])
disp(' ')


if sqw_type
    disp( ' Extent of data: ')
    disp(['     Number of spe files: ',num2str(nfiles)])
    disp(['        Number of pixels: ',num2str(npixtot)])
    disp(' ')
end

[title_main, title_pax, title_iax, display_pax, display_iax] = sqw_data_plot_titles (data);
if ndim~=0
    npchar = '[';
    for i=1:ndim
        npchar = [npchar,num2str(sz(data.dax(i))),'x'];   % size along each of the display axes
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
if sqw_type
    if npixtot < 0.5   % in case so huge that can no longer hold integer with full precision
        disp(' WARNING: The dataset contains no counts')
        disp(' ')
    end
end
