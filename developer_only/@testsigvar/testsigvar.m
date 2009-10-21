function w=testsigvar(varargin)
% Constructor for sigvar object
%
%   >> w = sigvar(s)
%   >> w = sigvar(s,e)
%   >> w = sigvar(s,e,title)
%
%   s       Array of signal values
%   e       Variances on values
%           If no variances, var = []
%   

if nargin==0    % default constructor
    w.s=[];
    w.e=[];
    w.title='<untitled>';
elseif nargin==1 && isa(varargin{1},'testsigvar')   % is a testsigvar object already
    w = varargin{1};
    return
elseif nargin==1 && isstruct(varargin{1})    % structure
    w = varargin{1};
    [ok,mess]=checkfields(w);
    if ~ok, error(mess), return, end
elseif nargin==1
    w.s=varargin{1};
    w.e=[];
    w.title='<untitled>';
    [ok,mess]=checkfields(w);
    if ~ok, error(mess), return, end
elseif nargin==2
    w.s=varargin{1};
    w.e=varargin{2};
    w.title='<untitled>';
    [ok,mess]=checkfields(w);
    if ~ok, error(mess), return, end
elseif nargin==3
    w.s=varargin{1};
    w.e=varargin{2};
    w.title=varargin{3};
    [ok,mess]=checkfields(w);
    if ~ok, error(mess), return, end
else
    error('Input argument(s) to constructor are invalid')
end

w=class(w,'testsigvar');
