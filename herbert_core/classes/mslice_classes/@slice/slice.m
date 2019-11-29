function wout = slice (varargin)
% Create mslice/Tobyfit slice object
% 
%   >> w=slice(file)          % read from file
%   >> w=slice(structure)     % create from structure


% Original author: T.G.Perring

classname='slice';

if nargin==1
    if isstruct(varargin{1})    % structure
        [ok,mess,wout]=checkfields(varargin{1});   % Make checkfields the ultimate arbiter of the validity of a structure
        if ok, wout = class(wout,classname); return, else error(mess); end
    elseif ischar(varargin{1}) && length(size(varargin{1}))==2 && size(varargin{1},1)==1
        if exist(varargin{1},'file') % file name
            [wout,ok,mess]=get_slice(varargin{1});
            if ~ok, error(mess); end
            [ok,mess,wout]=checkfields(wout);   % Make checkfields the ultimate arbiter of the validity of a structure
            if ok, wout = class(wout,classname); return, else error(mess); end
        else
            error('File does not exist')
        end
    else
        error('Check arguments')
    end
elseif nargin==0
    wout=default_slice;
    [ok,mess,wout]=checkfields(wout);   % Make checkfields the ultimate arbiter of the validity of a structure
    if ok, wout = class(wout,classname); return, else error(mess); end
else
    error('Check number of arguments')
end

%--------------------------------------------------------------------------------
function d=default_slice
% Make default slice structure

d.xbounds=[-1,1];
d.ybounds=[-1,1];
d.x=0; d.y=0; d.c=NaN; d.e=0;
d.npixels=0;
d.pixels=zeros(0,7);
d.x_label='x coordinate of cut'; d.y_label='y coordinate of cut'; d.z_label='Intensity'; d.title='Default empty slice';
d.x_unitlength=1; d.y_unitlength=1;
d.SliceFile=''; d.SliceDir='';
