function w=sigvar(varargin)
% Constructor for sigvar object
%
%   >> w = sigvar(s)
%   >> w = sigvar(s,e)
%
%   s       Array of signal values
%   e       Variances on values
%           If no variances, var = []
%   

if nargin==0    % default constructor
    w.s=[];
    w.e=[];
elseif nargin==1 && isa(varargin{1},'sigvar')   % is a sigvar object already
    w = varargin{1};
    return
elseif nargin==1 && isstruct(varargin{1})    % structure
    w = varargin{1};
    [ok,mess]=checkfields(w);
    if ~ok, error(mess), return, end
elseif nargin==1
    w.s=varargin{1};
    w.e=[];
    [ok,mess]=checkfields(w);
    if ~ok, error(mess), return, end
elseif nargin==2
    w.s=varargin{1};
    w.e=varargin{2};
    [ok,mess]=checkfields(w);
    if ~ok, error(mess), return, end
else
    error('Input argument(s) to constructor are invalid')
end

w=class(w,'sigvar');
