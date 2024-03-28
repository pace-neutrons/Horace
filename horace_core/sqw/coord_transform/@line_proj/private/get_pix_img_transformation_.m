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

% Optimization, necessary to combine pix_to_img transformation matrix and
% aligment matrix into single transformation matrix
if ~isempty(varargin) && (isa(varargin{1},'PixelDataBase')|| isa(varargin{1},'pix_metadata'))
    pix = varargin{1};
    if pix.is_misaligned
        alignment_needed = true;
        alignment_mat = pix.alignment_matr;
    else
        alignment_needed = false;
    end
else
    alignment_needed = false;
end
if ~isempty(obj.q_to_img_cache_)
    q_to_img   = obj.q_to_img_cache_(1:ndim,1:ndim);
    shift      = obj.q_offset_cache_(1:ndim);
    img_scales = obj.img_scales_(1:ndim);
    if alignment_needed
        q_to_img(1:3,1:3)  = q_to_img(1:3,1:3)*alignment_mat;
        % Note inversion! It is correct -- see how it used in transformation
        shift(1:3)         = alignment_mat'*shift(1:3);
    end
    return;
end
%

[q_to_img,img_scales,rlu_to_q,obj] = projtransf_to_img_(obj);
% Modern alignment with rotation matrix attached to pixel
% coordinate system
if alignment_needed
    q_to_img  = q_to_img*alignment_mat;
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
    if alignment_needed
        % Note inversion! It is correct -- see how it used in transformation
        shift = alignment_mat'*shift(:);
    end
else % do not convert anything
end
