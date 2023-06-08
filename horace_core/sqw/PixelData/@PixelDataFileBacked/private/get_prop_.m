function  prp = get_prop_(obj,fld)
%GET_PROP_ main part of PixelDataFileBacked property getter
% Inputs:
% obj -- initialized instance of PixelDataFileBacked class
% fld -- string which describes the names of Pixel fields to retrieve
%
% Returns:
% prp  -- [N x Npix] array of data values where N is the number of pixel
%         data fields defined by fld property and Npix is the total number
%         of pixels stored in PixelData memory-based class.

[pix_idx_start, pix_idx_end] = obj.get_page_idx_(obj.page_num_);

if isempty(obj.f_accessor_)
    prp = zeros(obj.get_field_count(fld), 0);
else
    idx = obj.FIELD_INDEX_MAP_(fld);
    if obj.is_misaligned_ && any(idx<4)
        acc_idx = unique([1:3,idx]);
        data = double(obj.f_accessor_.Data.data(acc_idx, ...
            pix_idx_start:pix_idx_end));
        pix_coord = (data(1:3,:)'*obj.alignment_matr_');
        % modify only data, which were aligned (e.g. in range 1:3)
        conv_idx = idx(idx<4);
        data(conv_idx,:) = pix_coord(:,conv_idx)';
        prp = data(idx,:);
    else
        prp = double(obj.f_accessor_.Data.data(idx, ...
            pix_idx_start:pix_idx_end));
    end
end
