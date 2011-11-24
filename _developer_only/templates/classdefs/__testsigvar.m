function w=testsigvar(varargin)
% Constructor for testsigvar object
%
%   >> w = testsigvar(s)
%   >> w = testsigvar(s,e)
%   >> w = testsigvar(s,e,title)
%
%   s       Array of signal values
%           If no signal, s = []
%   e       Variances on values
%           If no variances, e = []
%           - Can be empty even if there is a non-empty signal, in which case variances are ignored
%           - If not empty, then must have iseqaul(size(s),size(e))==true
%   title   Title: character array or cellstr
%   

% Original author: T.G.Perring

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
