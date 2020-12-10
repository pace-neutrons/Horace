function wout = cut(source, varargin)
%%CUT
%

if is_string(source)
    pixel_page_size = get(hor_config, 'pixel_page_size');
    sqw_obj = sqw(source, 'pixel_page_size', pixel_page_size);
else
    sqw_obj = source;
end

wout = cut(sqw_obj, varargin{:});
