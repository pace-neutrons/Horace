function wout = cut (varargin)
% Create mslice/Tobyfit cut object
% 
%   >> w=cut(file)          % read from file
%   >> w=cut(structure)     % create from structure


% Original author: T.G.Perring

classname='cut';

if nargin==1
    if isstruct(varargin{1})    % structure
        [ok,mess,wout]=checkfields(varargin{1});   % Make checkfields the ultimate arbiter of the validity of a structure
        if ok, wout = class(wout,classname); return, else error(mess); end
    elseif ischar(varargin{1}) && length(size(varargin{1}))==2 && size(varargin{1},1)==1
        if exist(varargin{1},'file') % file name
            [wout,ok,mess]=get_cut(varargin{1});
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
    wout=default_cut;
    [ok,mess,wout]=checkfields(wout);   % Make checkfields the ultimate arbiter of the validity of a structure
    if ok, wout = class(wout,classname); return, else error(mess); end
else
    error('Check number of arguments')
end

%--------------------------------------------------------------------------------
function d=default_cut
% Make default cut structure

d.x=0; d.y=0; d.e=0;
d.npixels=1;
d.pixels=[1,0,0,0,0,0];
d.x_label='x coordinate of cut'; d.y_label='Intensity'; d.title='Default empty cut';
d.CutFile=''; d.CutDir='';
