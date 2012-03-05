function set_efix (varargin)
% Set default fixed energy and emode (0=elastic, 1=direct, 2=indirect) for the current run
%     efix  - incident or final energy (meV)
%     emode - 0,1,2 for elastic, direct geometry, indirect geometry
%
% Syntax:
%   >> set_efix (efix)      efix = +ve for direct geometry (sets emode=1)
%                           efix = -ve for indirect geometry (sets emode=2)
%                           efix = 0   for elastic (sets emode=0)
% or explicitly set both:
%   >> set_efix (efix, emode)    
%                          (efix > 0 if inelastic; set to zero if elastic)
%
% To view current values:
%   >> set_efix
%
% Inverse function of set_efix

global mgenie_globalvars

% Check arguments and set parameters:
if nargin==1
    if isa(varargin{1},'double') && isscalar(varargin{1})
        efix = varargin{1};
        if efix == 0
            mgenie_globalvars.unitconv.efix = 0;
            mgenie_globalvars.unitconv.emode = 0;
        elseif efix > 0
            mgenie_globalvars.unitconv.efix = efix;
            mgenie_globalvars.unitconv.emode = 1;
        else
            mgenie_globalvars.unitconv.efix = -efix;
            mgenie_globalvars.unitconv.emode = 2;
        end
    else
        error('Check argument type and size')
    end
    
elseif nargin==2
    if isa(varargin{1},'double') && isscalar(varargin{1}) && isa(varargin{2},'double') && isscalar(varargin{2})
        efix = varargin{1};
        emode = varargin{2};
        if ~(emode==0 || emode==1 || emode==2)
            error ('emode must be 0,1,2')
        end
        if efix==0 && emode>0  % inelastic and fixed energy zero
            error ('Fixed energy must be positive if inelastic (i.e. emode > 0)')
        end
        if emode~=0
            mgenie_globalvars.unitconv.efix = efix;
        else
            mgenie_globalvars.unitconv.efix = 0; % explicily set to zero for clarity when debugging.
        end
        mgenie_globalvars.unitconv.emode = emode;
    else
        error('Check argument typse and sizes')
    end
    
elseif nargin > 2
    error ('Check number of arguments')
end

% Print values to screen
disp(['                       Fixed energy (meV) : ',num2str(mgenie_globalvars.unitconv.efix,5)])
disp(['            Moderator-sample distance (m) : ',num2str(mgenie_globalvars.unitconv.x1,5)])
disp(['                              Energy mode : ',num2str(mgenie_globalvars.unitconv.emode)])
disp(' ')
