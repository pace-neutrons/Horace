function [obj,al_info,alatt,angdeg] = remove_legacy_alignment(obj,varargin)
%REMOVE_LEGACY_ALIGNMENT:  modify crystal lattice and orientation matrix
% to remove legacy alignment applied to the crystal earlier.
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
% Two input parameters duplicate the input provided in varargin (for runing realignment within the sqw object):
% alatt   -- lattice parameters with new values for lattice. (presumably
%            before alignment)
% angdeg  -- lattice angles with values necessary to set.
%            Of one is present, another one have to be present.
%            If these values are missing, assumes that the lattice have not
%            been changed.
%
%
% Throws invalid_argument if identified that crystal has not been realigned

if nargin > 1
    if nargin ~= 3
        error('HORACE:DnDBase:invalid_argument', ...
            'If lattice parameters are provided as input (%s) lattice angles have to be provieded too. Got %d input parameters', ...
            disp2str(varargin{1}),nargin);
    end
    % use tmp proj class to check the lattice parameters validity
    tmp_proj = ortho_proj('alatt',varargin{1},'angdeg',varargin{2});
    alatt = tmp_proj.alatt;
    angdeg = tmp_proj.angdeg;
    if any(abs(alatt-obj.alatt)>4*eps('single')) || ...
            any(abs(angdeg-obj.angdeg)>4*eps('single'))
        lattice_modified = true;
    else
        lattice_modified = false;
    end
else
    alatt            = obj.alatt;
    angdeg           = obj.angdeg;
    lattice_modified = false;
end
ub_inv_legacy = obj.proj.ub_inv_legacy;
if isempty(ub_inv_legacy)
    error('HORACE:DnDBase:invalid_argument', ...
        'Object does not contain legacy alignment matrix. Nothing to do');
end

if all(abs(subdiag_elements(ub_inv_legacy))<4*eps('single')) && ~lattice_modified
    % nothing to do, object has not been aligned
    error('HORACE:DnDBase:invalid_argument', ...
        'Object has not been legacy-aligned. Nothing to do');
end

rotmat = obj.proj.bmatrix(3)*ub_inv_legacy;
rot_vec = rotmat_to_rotvec2(rotmat);
al_info = crystal_alignment_info(alatt,angdeg,rot_vec);
% clear legacy alignment matrix
obj.proj.ub_inv_legacy = [];
if lattice_modified
    obj.proj.alatt  = alatt;
    obj.proj.angdeg = angdeg;
end
obj.axes = obj.proj.copy_proj_defined_properties_to_axes(obj.axes);
