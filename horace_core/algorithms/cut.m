function wout = cut(source, varargin)
%%CUT
%

if is_string(source)
    ldr = sqw_formats_factory.instance().get_loader(source);
    if ldr.sqw_type
        pixel_page_size = get(hor_config, 'pixel_page_size');
        sqw_obj = sqw(source, 'pixel_page_size', pixel_page_size);
    else
        sqw_obj = ldr.get_dnd(source);
    end
    ldr.delete();
else
    sqw_obj = source;
end

wout = cut(sqw_obj, varargin{:});
