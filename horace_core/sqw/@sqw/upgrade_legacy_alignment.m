function [obj,deal_info] = upgrade_legacy_alignment(obj,varargin)
%UPGRADE_LEGACY_ALIGNMENT:  modify crystal lattice and orientation matrix
% to remove legacy alignment applied to the crystal earlier.
% Inputs:
% obj    -- legacy aligned sqw object. Algorithm throws if the object has
%           not been realigned using legacy algorithm.
% Optional
% alatt   -- lattice parameters with new values for lattice. (presumably
%            before alignment)
% angdeg  -- lattice angles with values necessary to set.
%            Of one is present, another one have to be present.
%            If these values are missing, assumes that the lattice have not
%            been changed.
% Outputs:
% wout    -- dealigned sqw object
% al_info -- instance of crystal_alignment_info class, containing alignment
%            parameters, used to do legacy alignment.
%


% Perform operations
% ------------------
for i=1:numel(obj)
    alatt_al  = obj.data.proj.alatt;
    angdeg_al = obj.data.proj.angdeg;
    [data,deal_info,no_alignment_found] = upgrade_legacy_alignment(obj(i).data,varargin{:});
    if no_alignment_found
        continue;
    end
    obj(i).data = data;
    exper = obj(i).experiment_info;
    exper = exper.upgrade_legacy_alignment(deal_info,alatt_al,angdeg_al);
    obj(i).experiment_info = exper;
    % set up inverted dealignment matrix as alignment matrix
    obj(i).pix.alignment_matr = deal_info.rotmat';
end
