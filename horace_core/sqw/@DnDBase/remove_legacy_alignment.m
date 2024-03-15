function [obj,deal_info] = remove_legacy_alignment(obj,u_to_rlu_instr,varargin)
%REMOVE_LEGACY_ALIGNMENT:  modify crystal lattice and orientation matrix
% to remove legacy alignment applied to the crystal earlier.
% Inputs:
% obj    -- legacy realigned dnd object. Algorithm throws if the object has
%           not been realigned using legacy algorithm.
% u_to_rlu_instr
%        -- u_to_rlu stored with IX_experiment. It is recovered only if
%           it is rotmat*inv(b_matrix), i.e. it has any under-diagonal elements;
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

if nargin > 2
    if nargin ~= 4
        error('HORACE:DnDBase:invalid_argument', ...
            ['If lattice parameters are provided as input (%s) lattice angles have to be provided too.\n',...
            ' Only got %d input parameters'], ...
            disp2str(varargin{1}),nargin);
    end
    % use tmp proj class to check the lattice parameters validity
    tmp_proj = line_proj('alatt',varargin{1},'angdeg',varargin{2});
    alatt0  = tmp_proj.alatt;
    angdeg0 = tmp_proj.angdeg;
else
    alatt0           = obj.alatt;
    angdeg0          = obj.angdeg;
end
if ~isa(obj.proj,'ubmat_proj')
    error('HORACE:DnDBase:invalid_argument', ...
        'Object does not contain legacy data. Nothing to do');
end
% This is also possible but unnecessary as
% THIS IS CORRECT ONLY IF proj == line_proj([1,0,0],[0,1,0],'type','aaa')
% u_to_rlu = obj.proj.u_to_rlu;
% if all(abs(subdiag_elements(u_to_rlu))<4*eps('single')) && ~lattice_modified
%     nothing to do, object has not been aligned
%     error('HORACE:DnDBase:invalid_argument', ...
%         'Object has not been legacy-aligned. Nothing to do');
% end
%
rotmat = obj.proj.bmatrix(4)*u_to_rlu_instr;
% get rotation parameters, which correspond to inverse rotation
rot_vec   = rotmat_to_rotvec2(rotmat(1:3,1:3)');
deal_info = crystal_alignment_info(alatt0,angdeg0,rot_vec);
obj = obj.change_crystal(deal_info );
