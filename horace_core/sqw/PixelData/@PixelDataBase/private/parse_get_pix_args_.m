function [pix_indices,ignore_range,raw_data,keep_precision,align] = ...
    parse_get_pix_args_(obj,accepts_logical,varargin)

[ok, mess, ignore_range, raw_data, keep_precision, align,argi] = ...
    parse_char_options(varargin, ...
    {'-ignore_range','-raw_data','-keep_precision','-align'});
if ~ok
    error('HORACE:PixelDataBase:invalid_argument',mess);
end

switch numel(argi)
    case 0
        [ind_min,ind_max] = obj.get_page_idx_();
       pix_indices = ind_min:ind_max;

    case 1
        pix_indices = argi{1};

        if islogical(pix_indices)
            if accepts_logical
                if numel(pix_indices) ~= obj.num_pixels
                    error('HORACE:PixelDataBase:invalid_argument',...                    
                        'number of logical arguments (%d) must be equal to number of pixels (%d)',...
                        numel(pix_indices),obj.num_pixels)
                end
            else
                pix_indices = obj.logical_to_normal_index_(pix_indices);
            end
        end

        if ~isindex(pix_indices)
            error('HORACE:PixelDataBase:invalid_argument',...
                'pixel indices should be an array of numeric positive numbers, which define indices or vector of logical values')
        end

        if any(pix_indices > obj.num_pixels)
            error('HORACE:PixelDataBase:invalid_argument', ...
                'Some numerical indices exceed the total number of pixels')
        end

    otherwise
        error('HORACE:PixelDataBase:invalid_argument', ...
            'Too many inputs provided to parse_get_pix_args_')
end
end
