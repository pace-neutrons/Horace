function [obj,deal_info] = remove_legacy_alignment(obj,varargin)
%REMOVE_LEGACY_ALIGNMENT:  modify crystal lattice and orientation matrix
% to remove legacy alignment applied to the crystal earlier.
% Inputs:
% obj    -- legacy realigned dnd object. Algorithm throws if the object has
%           not been realigned using legacy algorithm.
% Optional
% alatt   -- lattice parameters with new values for lattice. (presumably
%            before alignment)
% angdeg  -- lattice angles with values necessary to set.
%            If one is present, another one have to be present.
%            If these values are missing, assumes that the lattice have not
%            been changed.
% Outputs:
% wout    -- dealigned dnd object
% deal_info -- instance of crystal_alignment_info class, containing alignment
%            parameters, opposite to initial alignment, so suitable for
%            dealignment
%
% Throws invalid_argument if identified that crystal has not been realigned

if nargin > 1
    if nargin ~= 3
        error('HORACE:DnDBase:invalid_argument', ...
            ['If lattice parameters are provided as input (%s) lattice angles have to be provided too.\n',...
			' Only got %d input parameters'], ...
            disp2str(varargin{1}),nargin);
    end
    % use tmp proj class to check the lattice parameters validity
    tmp_proj = line_proj('alatt',varargin{1},'angdeg',varargin{2});
    alatt0  = tmp_proj.alatt;
    angdeg0 = tmp_proj.angdeg;
    if any(abs(alatt0-obj.alatt)>4*eps('single')) || ...
            any(abs(angdeg0-obj.angdeg)>4*eps('single'))
        lattice_modified = true;
    else
        lattice_modified = false;
    end
else
    alatt0           = obj.alatt;
    angdeg0          = obj.angdeg;
    lattice_modified = false;
end
if ~isa(obj.proj,'ubmat_proj')
    error('HORACE:DnDBase:invalid_argument', ...
        'Object does not contain legacy data. Nothing to do');    
end
u_to_rlu = obj.proj.u_to_rlu;
if all(abs(subdiag_elements(u_to_rlu))<4*eps('single')) && ~lattice_modified
    % nothing to do, object has not been aligned
    error('HORACE:DnDBase:invalid_argument', ...
        'Object has not been legacy-aligned. Nothing to do');
end
% Re #1591 TODO:
% THIS IS CORRECT ONLY IF proj == line_proj([1,0,0],[0,1,0],'type','aaa')
rotmat = obj.proj.bmatrix(4)*u_to_rlu;
% get rotation parameters, which correspond to 
rot_vec   = rotmat_to_rotvec2(rotmat(1:3,1:3)');
deal_info = crystal_alignment_info(alatt0,angdeg0,rot_vec);
if lattice_modified
    obj.proj.alatt  = alatt0;
    obj.proj.angdeg = angdeg0;
end
obj.axes = obj.proj.copy_proj_defined_properties_to_axes(obj.axes);
