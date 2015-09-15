function wout=IX_map(varargin)
% Constructor for IX_map object. There are numerous ways to specify the map
%
% Read from file:
% ---------------
%   >> w = IX_map(filename)                 % Read from ascii file, but ignore workspace numbers
%   >> w = IX_map(filename,'wkno')          % Read workspace numbers as well
%
% Spectrum numbers:
% -----------------
%   >> w = IX_map(isp)                      % Single workspace with a single spectrum
%   >> w = IX_map(isp_arr)                  % Map with one spectrum per workspace
%   >> w = IX_map(isp_lo, isp_hi)           % Map with one spectrum per workspace,
%                                            equivalent to IX_map(isp_lo:isp_hi)
%   >> w = IX_map(isp_lo, isp_hi, nstep)    % Map with each workspace containing
%                                            nstep spectra starting at isp_lo,
%                                            isp_lo+nstep, isp_lo+2*nstep,...
%
%   The arguments is_lo, is_hi, nstep, can be vectors. The result is equivalent
%   to the concatenation of IX_map applied to the arguments element-by-element i.e.
%       IX_map (is_lo, is_hi, step)
%   is equivalent to a combination of the output of
%       IX_map(is_lo(1),is_hi(1),nstep(1)), IX_map(is_lo(2),is_hi(2),nstep(2)), ...
%
%   >> w = IX_map(...,'wkno',wk)            % in addition, give an array of numbers to
%                                            uniquely identify each workspace.
%
% Cell array specification:
% -------------------------
%   >> w = IX_map(cell)             % cell array where each element is an array of
%                                    spectrum numbers
%
%   >> w = IX_map(cell,'wkno',wk)   % in addition, give an array of numbers to
%                                    uniquely identify each workspace.
%
% Structure:
% ----------
%   >> w = IX_map(struc)            % Structure with fields of IX_map object (see below)
%
%   >> w = IX_map(struc,'wkno',wk)
%
% In all cases, if the workspace numbers are not given (i.e. they are 'un-named')
% they will be left undefined, and workspaces can be addressed by their index
% in the range 1 to nw, where nw is the total number of workspaces.
%
%
% Contents of map object:
% -----------------------
%   ns      Row vector of number of spectra in each workspace. There must be
%          at least one workspace. ns(i)=0 is permitted (it means no spectra in ith workspace)
%   s       Row vector of spectrum indicies in workspaces concatenated together. The
%          spectrum numbers are sorted into numerically increasing order for
%          each workspace
%   wkno    Workspace numbers (think of them as the 'names' of the workspaces).
%          Must be unique, and greater than or equal to one.
%           If [], this means leave undefined.

% Original author: T.G.Perring

classname='IX_map';

% Catch default constructor or existing IX_map
% --------------------------------------------
if nargin==0
    % Default constructor: single empty workspace
    wout.ns=0;
    wout.s=zeros(1,0);
    wout.wkno=zeros(1,0);
    [ok,mess,wout]=checkfields(wout);   % Make checkfields the ultimate arbiter of the validity of a structure
    if ok, wout = class(wout,classname); return, else error(mess); end
    
elseif nargin==1 && isa(varargin{1},classname)
    % Is a map object already
    wout = varargin{1};
    return
end


% Find 'wkno' option, if given
% -----------------------------
wkno_def=zeros(1,0);
if nargin>1 && is_string(varargin{end}) && strncmpi(varargin{end},'wkno',numel(varargin{end}))    % ...,'wkno')
    narg=nargin-1;
    opt=true;
    optval=false;
elseif nargin>2 && is_string(varargin{end-1}) && strncmpi(varargin{end-1},'wkno',numel(varargin{end-1}))    % ...,'wkno',val)
    narg=nargin-2;
    opt=true;
    optval=true;
    wkno=varargin{end};
else
    narg=nargin;
    opt=false;
    optval=false;
end


% Parse the rest of the input
% ---------------------------
if nargin==1 && isstruct(varargin{1})
    % Structure with the fields of a map object is permitted
    wout = varargin{1};
    if optval
        wout.wkno=wkno;     % only override an existing wkno if one is provided in argument list
    elseif opt
        error('Must give replacement workspaces numbers if ''wkno'' option was provided')
    end
    
elseif narg==1 && iscell(varargin{1})
    % Cell array input
    [wout,ok,mess]=cellarray_to_map(varargin{1});
    if ~ok, error(mess), end
    if optval
        wout.wkno=wkno;     % only override an existing wkno if one is provided in argument list
    elseif opt
        error('Must give replacement workspaces numbers if ''wkno'' option was provided')
    else
        wout.wkno=wkno_def;
    end
    
elseif narg==1 && is_string(varargin{1})
    % File name input
    if ~isempty(varargin{1})
        [wout,ok,mess]=get_map(varargin{1});
        if ~ok, error(mess), end
        if optval
            wout.wkno=wkno;     % if ...'wkno') use value read from file, if ...'wkno',val) use provided value
        elseif ~opt
            wout.wkno=wkno_def; % use the default
        end
    else
        error('File name cannot be an empty string')
    end
    
elseif narg<=3
    [wout,ok,mess]=arrays_to_map(varargin{1:narg});
    if ~ok, error(mess), end
    if optval
        wout.wkno=wkno;     % only override an existing wkno if one is provided in argument list
    elseif opt
        error('Must give replacement workspace numbers if ''wkno'' option was provided')
    else
        wout.wkno=wkno_def;
    end
    
else
    error('Check number and/or type of arguments')
    
end

[ok,mess,wout]=checkfields(wout);   % Make checkfields the ultimate arbiter of the validity of a structure
if ok, wout = class(wout,classname); return, else error(mess); end
