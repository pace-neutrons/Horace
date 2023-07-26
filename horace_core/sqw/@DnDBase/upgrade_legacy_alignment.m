function [obj,al_info,no_alignment,alatt0,angdeg0] = upgrade_legacy_alignment(obj,varargin)
%UPDATE_LEGACY_ALIGNMENT:  modify crystal lattice and orientation matrix
% to remove legacy alignment applied to the crystal earlier and place
% changes related to current alignment instead
%
% Inputs:
% obj    -- legacy realigned dnd object. Algorithm throws if the object has
%           not been realigned using legacy algorithm.
% Optional
% alatt   -- lattice parameters with new values for lattice. (presumably
%            before alignment)
% angdeg  -- lattice angles with values necessary to set.
%            Of one is present, another one have to be present.
%            If these values are missing, assumes that the lattice have not
%            been changed.
% Outputs:
% wout    -- dealigned dnd object
% al_info -- instance of crystal_alignment_info class, containing alignment
%            parameters, used to do legacy alignment.
% no_alignment
%         -- true if no legacy alignment was identified on the object
% alatt0   -- lattice parameters with new values for lattice. (presumably
%            before alignment)
% angdeg0  -- lattice angles with values necessary to set.
%            Of one is present, another one have to be present.
%
% Does nothing if identified that crystal has not been legacy realigned

alatt_al     = obj.alatt;
angdeg_al    = obj.angdeg;
no_alignment = false;
try
    [obj,al_info,alatt0,angdeg0] = remove_legacy_alignment(obj,varargin{:});
catch ME
    if strcmp(ME.identifier,'HORACE:DnDBase:invalid_argument') && ...
            contains(ME.message,'Nothing to do')
        no_alignment  = true;
        alatt0 = [];
        angdeg0 = [];
        return
    else
        rethrow(ME);
    end
end

al_info.alatt  = alatt_al;
al_info.angdeg = angdeg_al;
obj = obj.change_crystal(al_info);