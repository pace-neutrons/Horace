function [obj,al_info] = upgrade_legacy_alignment(obj,varargin)
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
    [data,al_info,no_alignment_found,alatt0,angdeg0] = upgrade_legacy_alignment(obj(i).data,varargin{:});
    if no_alignment_found
        continue;
    end
    obj(i).data = data;
    exper = obj(i).experiment_info;
    exper = exper.upgrade_legacy_alignment(al_info,alatt0,angdeg0);
    obj(i).experiment_info = exper;
    obj(i).pix.alignment_matr = al_info.rotmat;
end
