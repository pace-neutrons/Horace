function pix_out = pack_get_pix_result_(obj,pix_data,ignore_range,raw_data,keep_precision,align)
% pack output of get_pixels method depending on various
% get_pixels input options
% Input:
% Original PixelDataBase object
% pix_data     -- array of raw pixel data
% ignore_range -- if true, do not calculate pixels range
% raw_data     -- if true, do not wrap pix_data into
%                 PixelDataBase class
% keep_precision
%              -- if true, keep original pixel precision
%                 intact. Do not make it double
% align        -- if true and data are misaligned, apply
%                 alignment matrix and dealign the data
%
misaligned = obj.is_misaligned;

if align && misaligned
    pix_data(1:3,:) = obj.alignment_matr*pix_data(1:3,:);
end

if ~keep_precision
    pix_data = double(pix_data);
end
if raw_data
    pix_out = pix_data;
    return;
end

pix_out = PixelDataMemory(pix_data);

if ~align && misaligned
    pix_out.alignment_matr  = obj.alignment_matr;
end

if ~ignore_range
    pix_out.data_range_ = pix_out.pix_minmax_ranges(pix_out.data);
end

end
