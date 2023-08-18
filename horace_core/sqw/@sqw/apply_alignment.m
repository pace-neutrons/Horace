function [obj,al_info] = apply_alignment(obj,al_info)
%APPLY_ALIGNMEMT Method takes realigned sqw object and applies the 
% alignment info stored in this object
% to pixels and image so the object becomes realigned as from
% the beginning and the aligment information is not necessary any more
% 
% Input:
% obj -- the realigned sqw object
% Optional
% al_info   -- crystal_alignment_info object, containing lattice, which
%              should replace current lattice. Rotation matrix, stored in
%              al_info class, will be ignored
%
if ~obj.pix.is_misaligned % nothing to do
    return
end
rotmat  = obj.pix.alignment_matr;
if nargin>1
    if ~isa(al_info,'crystal_alignment_info')
        error('HORACE:sqw:invalid_argument', ...
            'Second argument, if provided, should be a crystal_alignment_info object. It is: %s', ...
            class(al_info))
    end
    % inverse rotation matrix
    al_info.rotmat = rotmat';
else
  rotvec  = rotmat_to_rotvec2(rotmat');
  alatt   = obj.data.proj.alatt;
  angdeg  = obj.data.proj.angdeg;  
  al_info = crystal_alignment_info(alatt,angdeg,rotvec);
end
obj.data = obj.data.change_crystal(al_info);
obj.data.proj.proj_aligned  = false;
obj.pix = obj.pix.apply_alignment();
