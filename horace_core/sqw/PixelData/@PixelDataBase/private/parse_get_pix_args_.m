function [abs_pix_indices,ignore_range,raw_data,keep_precision] = parse_get_pix_args_(obj,abs_pix_indices,varargin)
% process get_pix arguments and return them in standard form suitable for
% usage in filebased and memory based classes
if nargin>1 && isnumeric(abs_pix_indices)
    if ~is_positive_int_vector_or_logical_vector(abs_pix_indices)
        error('HORACE:PixelDataFilebacked:invalid_argument',...
        'pixel indexes should be an array of numeric positive numbers, which define intexes or vector of logical values')
    end
    argi = varargin;
else
    if nargin >= 2
        argi = [abs_pix_indices,varargin(:)];
    else
        argi = varargin;
    end
    [ind_min,ind_max] = obj.get_page_idx_();
    abs_pix_indices = [ind_min:ind_max];    
end

if islogical(abs_pix_indices)
    if numel(abs_pix_indices) > obj.num_pixels
        if any(abs_pix_indices(obj.num_pixels + 1:end))
            error('HORACE:PixelDataFilebacked:invalid_argument', ...
                ['The logical indices contain a true value outside of ' ...
                'the pixel ranges.']);
        else
            abs_pix_indices = abs_pix_indices(1:obj.num_pixels);
        end
    end
    abs_pix_indices = find(abs_pix_indices);
else
    if max(numel(abs_pix_indices) > obj.num_pixels)
        error('HORACE:PixelDataFilebacked:invalid_argument', ...
            'The numerical indexes exceed the pixel number')
    end
end

[ok,mess,ignore_range,raw_data,keep_precision] = parse_char_options(argi , ...
    {'-ignore_range','-raw_data','-keep_precision'});
if ~ok
    error('HORACE:PixelDataFilebacked:invalid_argument',mess);
end



function is = is_positive_int_vector_or_logical_vector(vec)
is = isvector(vec) && (islogical(vec) || (all(vec > 0 & all(floor(vec) == vec))));


