function wout = cut(source, varargin)
%%CUT
%
DND_CLASSES = {'d0d', 'd1d', 'd2d', 'd3d', 'd4d'};

if is_string(source)
    ldr = sqw_formats_factory.instance().get_loader(source);
    if ldr.sqw_type
        pixel_page_size = get(hor_config, 'pixel_page_size');
        sqw_dnd_obj = sqw(source, 'pixel_page_size', pixel_page_size);
    else
        sqw_dnd_obj = ldr.get_dnd(source);
    end
    ldr.delete();
elseif isa(source, 'sqw') || ismember(class(source), DND_CLASSES)
    sqw_dnd_obj = source;
else
    error('HORACE:cut', ...
          ['Cannot take cut of object of class ''%s''.\n' ...
           'Argument ''source'' must be sqw, dnd or a valid file path.'], ...
          class(source));
end

wout = cut(sqw_dnd_obj, varargin{:});
