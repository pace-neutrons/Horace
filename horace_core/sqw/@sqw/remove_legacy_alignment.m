function [obj,al_info] = remove_legacy_alignment(obj,varargin)
%REMOVE_LEGACY_ALIGNMENT:  modify crystal lattice and orientation matrix
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
    [data,al_info] = remove_legacy_alignment(obj(i).data,varargin{:});
    obj(i).data = data;
    obj(i).experiment_info = obj(i).experiment_info.remove_legacy_alignment(al_info);
end
