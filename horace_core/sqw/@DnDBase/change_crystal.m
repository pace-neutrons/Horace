function wout = change_crystal(obj,alignment_info,varargin)
% Change the crystal lattice and orientation of an dnd object or array of objects
%
%   >> obj=change_crystal(obj,alignment_info)
% Input:
% -----
%   w           Input sqw object or array of sqw objects
%
%   >> obj=change_crystal(obj,alignment_info)
%
% obj            -- initialized instance of Experiment object
%
% alignment_info -- helper class, containing the information
%                   about the crystal alignment, returned by refine_crystal
%                   routine. Type:
%                  >> help refine_crystal  for more details.
%
% Output:
% -------
%   wout        Output dnd object with changed crystal lattice parameters and orientation


if ~isa(alignment_info,'crystal_alignment_info')
    error('HORACE:DnDBase:invalid_argument',...
        ['Old interface to modify the crystal alignment is deprecated.\n', ...
        ' Use crystal_alignment_info class obtained from "refine_crystal" routine to realign crystal.\n', ...
        ' Call >>help refine_crystal for the details']);
end


wout = obj;

alatt  = alignment_info.alatt;
angdeg = alignment_info.angdeg;
for i=1:numel(obj)
    legacy_mode = alignment_info.hkl_mode;
    this_alignment = alignment_info;

    if legacy_mode
        this_alignment.hkl_mode  = true;
        rlu_corr = this_alignment.get_corr_mat(obj.proj);
        rlu_to_u = wout(i).proj.bmatrix();
        proj = wout(i).proj;
        % img_offset is not the property of the projection but if it was: 
        %proj.img_offset(1:3)=rlu_corr*wout(i).img_offset(1:3)';
        % here we apply modifications to image_offset converting it into 
        % offset (hkle)
        proj.offset = 0;
        proj.alatt  = alatt;
        proj.angdeg = angdeg;
        img_offset     = wout(i).img_offset;        
        new_img_offset = rlu_corr*img_offset(1:3)';
        proj           = proj.set_ub_inv_compat(rlu_corr/rlu_to_u);
        offset = proj.transform_img_to_hkl(new_img_offset(:));
        proj.offset    = [offset;img_offset(4)];
        %
        wout(i).proj = proj;        
    else
        [wout(i).proj,wout(i).axes] = wout(i).proj.align_proj(alignment_info,wout(i).axes);
    end
end
