function [q_to_img,shift,img_scales,obj]=get_pix_img_transformation_(obj,ndim,varargin)
%get_pix_img_transformation_    Return the transformation, necessary for conversion
%from pix to image coordinate system and vice-versa
%
% Input:
% ndim -- number of dimensions in the pixels coordinate array
%         (3 or 4). Depending on this number the routine
%         returns 3D or 4D transformation matrix
% Optional:
% pix_transf_info
%          -- PixelDataBase or pix_metadata class, providing the
%             information about pixel alignment. If present and
%             pixels are misaligned, contains additional rotation
%             matrix, used for aligning the pixels data into
%             Crystal Cartesian coordinate system
% Outputs:
% q_to_img -- [ndim x ndim] matrix used to transform pixels
%             in Crystal Cartesian coordinate system to image
%             coordinate system
% shift    -- [1 x ndim] array of the offsets of image coordinates
%              expressed in Crystal Cartesian coordinate system
% img_scales
%          -- [1 x ndim] array of scales along the image axes used
%             in the transformation

if ~obj.alatt_defined||~obj.angdeg_defined
    error('HORACE:line_proj:runtime_error', ...
        'Attempt to use coordinate transformations before lattice is defined. Define lattice parameters first')
end

if ~isempty(varargin) && (isa(varargin{1},'PixelDataBase')|| isa(varargin{1},'pix_metadata'))
    pix = varargin{1};
    if pix.is_misaligned 
        alignment_needed = true;
        alignment_mat = pix.alignment_matr;
        if obj.proj_aligned_ % double rotate pixels as projection rotated 
            % in opposite direction to pixels
            alignment_mat = alignment_mat*alignment_mat;
        end
    else
        alignment_needed = false;
    end
else
    alignment_needed = false;
end
if ~isempty(obj.q_to_img_cache_) && isempty(obj.ub_inv_legacy)
    q_to_img   = obj.q_to_img_cache_(1:ndim,1:ndim);
    shift      = obj.q_offset_cache_(1:ndim);
    img_scales = obj.ulen_cache_(1:ndim);
    if alignment_needed
        q_to_img  = q_to_img*alignment_mat;
    end
    return;
end
%
if isempty(obj.ub_inv_legacy)
    [q_to_img,img_scales,rlu_to_q,obj] = projtransf_to_img_(obj);
    % Modern alignment with rotation matrix attached to pixel
    % coordinate system
    if alignment_needed
        q_to_img  = q_to_img*alignment_mat;
    end
else% Legacy alignment, with multiplication of rotation matrix
    [rlu_to_u,~,img_scales]  = projaxes_to_rlu_legacy_(obj, [1,1,1]);
    u_to_rlu_ = obj.ub_inv_legacy; % psi = 0; inverted b-matrix
    q_to_img  = (rlu_to_u*u_to_rlu_);
    rlu_to_q  = inv(u_to_rlu_);
end
%
if ndim==4
    shift  = obj.offset;
    rlu_to_q  = [rlu_to_q,[0;0;0];[0,0,0,1]];
    q_to_img = [q_to_img,[0;0;0];[0,0,0,1]];
    img_scales = [img_scales(:)',1];
elseif ndim == 3
    shift  = obj.offset(1:3);
else
    error('HORACE:orhto_proj:invalid_argument',...
        'The ndim input may be 3 or 4  actually it is: %s',...
        evalc('disp(ndim)'));
end
if nargout > 1
    % convert shift, expressed in hkl into crystal Cartesian
    shift = rlu_to_q *shift(:);
else % do not convert anything
end
