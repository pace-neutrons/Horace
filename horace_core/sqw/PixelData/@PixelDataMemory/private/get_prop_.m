function prp = get_prop_(obj, fld)
%GET_PROP_ main part of the mem-based property accessor
%
% Inputs:
% obj -- initialized instance of mem-based PixelData class
% fld -- string which describes the names of Pixel fields to retrieve
%
% Returns:
% prp  -- [N x Npix] array of data values where N is the number of pixel
%         data fields defined by fld property and Npix is the total number
%         of pixels stored in PixelData memory-based class.
% 
idx = obj.FIELD_INDEX_MAP_(fld);
if obj.is_misaligned_ && any(idx<4)
    data = obj.data_;
    pix_coord = (data(1:3,:)'*obj.alignment_matr_');
    % modify only indexes, which were aligned (e.g. in range 1:3)
    conv_idx = idx(idx<4);
    data(conv_idx,:) = pix_coord(:,conv_idx)';
    prp = data(idx,:);
else
    prp = obj.data_(idx, :);
end
