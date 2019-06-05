function w=IX_divergence_profile(varargin)
% Constructor for IX_fermi_chopper object
%
%   >> div = IX_divergence_profile (angle,profile)
%
%   >> div = IX_divergence_profile (name,...)
%
%   name            Name of the divergence profile (e.g. 'LET new vertical')
%   angle           Vector of divergences (radians)
%   profile         Vector with profile. The first and last elements must be
%                  zero, and all other elements must be >= 0. Does not need to be
%                  normalised.
%
% If the profile is not normalised this will be performed during object
% construction.
%
% If the profie is 
%
% Original author: T.G.Perring

if nargin==0    % default constructor
    w.name = '';
    w.angle = 0;
    w.profile = 0;
    
elseif nargin==1 && isa(varargin{1},'IX_divergence_profile')   % is an object already
    w = varargin{1};
    return
    
elseif nargin==1 && isstruct(varargin{1})    % structure
    w = varargin{1};
    [ok,mess,w]=checkfields(w);
    if ~ok, error(mess), return, end
    
else
    if is_string(varargin{1})
        w.name = varargin{1};
        noff=1;
    else
        w.name = '';
        noff=0;
    end
    if nargin-noff==2
        w.angle  = varargin{noff+1};
        w.profile = varargin{noff+2};
    else
        error('Check number of input arguments')
    end
    [ok,mess,w]=checkfields(w);
    if ~ok, error(mess), return, end
    
end

w=class(w,'IX_divergence_profile');
