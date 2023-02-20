function [abs_pix_indices,ignore_range,raw_data,keep_precision] = parse_get_pix_args_(obj,varargin)
% process get_pix arguments and return them in standard form suitable for
% usage in filebased and memory based classes

[ok, mess, ignore_range, raw_data, keep_precision, argi] = ...
    parse_char_options(varargin , {'-ignore_range','-raw_data','-keep_precision'});
if ~ok
    error('HORACE:PixelDataBase:invalid_argument',mess);
end

switch numel(argi)
  case 0
    [ind_min,ind_max] = obj.get_page_idx_();
    abs_pix_indices = [ind_min:ind_max];

  case 1
    abs_pix_indices = argi{1};

    if islogical(abs_pix_indices)
        abs_pix_indices = obj.logical_to_normal_index_(abs_pix_indices);
    end

    if ~isindex(abs_pix_indices)
        error('HORACE:PixelDataBase:invalid_argument',...
              'pixel indices should be an array of numeric positive numbers, which define indices or vector of logical values')
    end

    if any(abs_pix_indices > obj.num_pixels)
        error('HORACE:PixelDataBase:invalid_argument', ...
              'Some numerical indices exceed the total number of pixels')
    end

  otherwise
        error('HORACE:PixelDataBase:invalid_argument', ...
              'Too many inputs provided to parse_get_pix_args_')

end


end
