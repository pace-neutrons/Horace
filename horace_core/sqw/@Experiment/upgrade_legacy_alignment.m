function obj=upgrade_legacy_alignment(obj,al_info,alatt0,angdeg0)
% UPGRADE_LEGACY_ALIGNMENT Change fields in the experiment with correction
% to remove legacy alignment applied to the crystal earlier and apply
% modern alignment to it.
%
%
% Inputs:
% obj    -- legacy realigned dnd object. Algorithm throws if the object has
%           not been realigned using legacy algorithm.
% al_info
%       -- instance of crystal_alignment_info class, containing information
%          about the alignment
% Optional
% alatt0  -- lattice parameters with new values for lattice. (presumably
%            before alignment)
% angdeg0 -- lattice angles with values necessary to set.
%            Of one is present, another one have to be present.
%            If these values are missing, assumes that the lattice have not
%            been changed.
% Outputs:
% wout    -- dealigned dnd object
% al_info -- instance of crystal_alignment_info class, containing alignment
%            parameters, used to do legacy alignment.

%
alatt_new  = al_info.alatt;
angdeg_new = al_info.angdeg;
if nargin>2
    al_info.alatt  = alatt0;
    al_info.angdeg = angdeg0;
else
end
obj = obj.remove_legacy_alignment(al_info);
al_info.alatt  = alatt_new;
al_info.angdeg = angdeg_new;
obj = obj.change_crystal(al_info);