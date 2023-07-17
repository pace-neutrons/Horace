function [obj,ax_block] = align_proj_(obj,alignment_info,varargin)
% Apply crystal alignment information to the projection and axes block 
% and realign it.
% Inputs:
% obj -- initialized instance of the projection info
% alignment_info
%     -- crystal_alignment_info class, containign information
%        about new alignment
% Returns:
% obj  -- the ortho_proj class, modified by information,
%         containing in the alignment info block
if isempty(obj.w_)
    uvw = [obj.u_(:),obj.v_(:)];
    w_defined = false;
else
    uvw = [obj.u_(:),obj.v_(:),obj.w_(:)];
    w_defined = true;
end
alignment_info.hkl_mode = true;
rlu_corr = alignment_info.get_corr_mat(obj);
uvw_corr = rlu_corr*uvw;
obj.u_ = uvw_corr(:,1)';
obj.v_ = uvw_corr(:,2)';
if w_defined
    obj.w_ = uvw_corr(:,3)';
end
if ~isequal(obj.offset_(1:3),zeros(1,3))
    obj.offset_(1:3) = (rlu_corr*obj.offset_(1:3)')';
end

obj.alatt_  = alignment_info.alatt;
obj.angdeg_ = alignment_info.angdeg;
obj = obj.check_combo_arg();
if isempty(varargin)
    ax_block = [];
    return
end
ax_block = varargin{1};
img_range = ax_block.img_range;
full_range = expand_box(img_range(1:3,1),img_range(1:3,2));
full_range_corr = rlu_corr*full_range; 

corr_range = [min(full_range_corr,[],2);max(full_range_corr,[],2)];
center = 0.5*(corr_range(1,:)+corr_range(2,:));
spawn = corr_range(2,:)-corr_range(1,:);
dist = norm(spawn,2);
new_range = [center-0.5*dist;center+0.5*dist];
img_range(:,1:3) = new_range;
ax_block.img_range = img_range;

if ~(all(abs(center)<4*eps('single')))
    obj.img_offset(1:3) = obj.img_offset(1:3)+center;
end
