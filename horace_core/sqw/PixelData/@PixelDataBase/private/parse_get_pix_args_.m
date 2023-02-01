function [abs_pix_indices,ignore_range,raw_data,keep_precision] = parse_get_pix_args_(obj,varargin)
% process get_pix arguments and return them in standard form suitable for
% usage in filebased and memory based classes

if nargin>1
    if ischar(varargin{1}) || isstring(varargin{1})
        [ind_min,ind_max] = obj.get_page_idx_();
        abs_pix_indices = [ind_min:ind_max];
        argi = varargin;
    else
        abs_pix_indices = varargin{1};
        if islogical(abs_pix_indices)
            abs_pix_indices = find(abs_pix_indices);
        end
        argi = varargin(2:end);
        if isnumeric(abs_pix_indices) && is_positive_int_vector(abs_pix_indices)
            if numel(abs_pix_indices) > obj.num_pixels
                error('HORACE:PixelDataFilebacked:invalid_argument', ...
                    'Total numner of input indexes exceed the toltal number of pixels')

            end
            if max(abs_pix_indices) > obj.num_pixels
                error('HORACE:PixelDataFilebacked:invalid_argument', ...
                    'Some or all numerical indexes exceed the toltal number of pixels')
            end
        else
            error('HORACE:PixelDataFilebacked:invalid_argument',...
                'pixel indexes should be an array of numeric positive numbers, which define intexes or vector of logical values')
        end
    end
else
    [ind_min,ind_max] = obj.get_page_idx_();
    abs_pix_indices = [ind_min:ind_max];
    argi = {};
end



[ok,mess,ignore_range,raw_data,keep_precision] = parse_char_options(argi , ...
    {'-ignore_range','-raw_data','-keep_precision'});
if ~ok
    error('HORACE:PixelDataFilebacked:invalid_argument',mess);
end



function is = is_positive_int_vector(vec)
is = isvector(vec) && ((all(vec > 0 & all(floor(vec) == vec))));
