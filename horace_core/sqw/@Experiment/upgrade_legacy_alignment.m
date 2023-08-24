function obj=upgrade_legacy_alignment(obj,deal_info,alatt,angdeg)
% UPGRADE_LEGACY_ALIGNMENT Change fields in the experiment with correction
% to remove legacy alignment applied to the crystal earlier and apply
% modern alignment to it.
%
%
% Inputs:
% obj    -- legacy realigned dnd object. Algorithm throws if the object has
%           not been realigned using legacy algorithm.
% deal_info
%        --  instance of crystal_alignment_info class, containing information
%            about dealignment of the legacy-aligned crystal
% Optional
% alatt   -- lattice parameters with values for aligned lattice to be set.
% angdeg  -- lattice angles with values for aligned lattice to be set.
%            If one is present, another one have to be present.
%            If these values are missing, assumes that the lattice have not
%            been changed.
% Outputs:
% wout    -- dnd object according to the new alignment algorithm.

obj = obj.remove_legacy_alignment(deal_info);
if nargin == 2
    alatt = deal_info.alatt;
    angdeg= deal_info.angdeg;
end

% create alignment info class, with rotation, opposite to dealignment
al_info = crystal_alignment_info(alatt,angdeg,-deal_info.rotvec);
obj = obj.change_crystal(al_info);