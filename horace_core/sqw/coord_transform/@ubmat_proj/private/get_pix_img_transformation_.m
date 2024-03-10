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


% if ~isempty(varargin) && (isa(varargin{1},'PixelDataBase')|| isa(varargin{1},'pix_metadata'))
%     pix = varargin{1};
%     if pix.is_misaligned
%         alignment_needed = true;
%         alignment_mat = pix.alignment_matr;
%         if obj.proj_aligned_ % double rotate pixels as projection rotated
%             % in opposite direction to pixels
%             alignment_mat = alignment_mat*alignment_mat;
%         end
%     else
%         alignment_needed = false;
%     end
% else
%     alignment_needed = false;
% end

bmat = obj.bmatrix(ndim);
if ndim==4
    shift      = obj.offset;
    img_scales = obj.img_scales;
    q_to_img   = bmat*obj.u_to_rlu;
elseif ndim == 3
    shift      = obj.offset(1:3);
    img_scales = obj.img_scales(1:3);
    q_to_img   = bmat*obj.u_to_rlu(1:3,1:3);
else
    error('HORACE:orhto_proj:invalid_argument',...
        'The ndim input may be 3 or 4  actually it is: %s',...
        evalc('disp(ndim)'));
end
if nargout > 1
    % convert shift, expressed in hkl into crystal Cartesian coordinate
    % system
    shift = bmat*shift(:);
else % do not convert anything
end
