function [efix,emode] = get_efix
% Get default fixed energy and emode (0=elastic, 1=direct, 2=indirect) for the current run:
%     efix  - incident or final energy (meV)
%     emode - 0,1,2 for elastic, direct geometry, indirect geometry
%
% Syntax:
%   >> efix = get_efix      efix = +ve for direct geometry (sets emode=1)
%                           efix = -ve for indirect geometry (sets emode=2)
%                           efix = 0   for elastic (sets emode=0)
% or explicitly get both
%   >> [efix, emode] = get_efix (efix)    
%                          (efix > 0 if inelastic; set to zero if elastic)
%
% Inverse function of set_efix

global mgenie_globalvars

if nargout==1
    if mgenie_globalvars.unitconv.emode==2
        efix = -mgenie_globalvars.unitconv.efix;
    else
        efix = mgenie_globalvars.unitconv.efix;
    end
elseif nargout==2
    efix = mgenie_globalvars.unitconv.efix;
    emode = mgenie_globalvars.unitconv.emode;
end
