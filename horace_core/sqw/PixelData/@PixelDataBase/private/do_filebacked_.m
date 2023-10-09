function isfb = do_filebacked_(num_pixels, scale_fac)
% function defines the rule to make pixels filebased or memory
% based
if ~(isnumeric(num_pixels)&&isscalar(num_pixels)&&num_pixels>=0)
    error('HORACE:PixelDataBase:invalid_argument', ...
        'Input number of pixels should have single non-negative value. It is %s', ...
        disp2str(num_pixels))
end
if isempty(scale_fac)
    [mem_chunk_size,scale_fac] = config_store.instance().get_value( ...
        'hor_config','mem_chunk_size','fb_scale_factor');
else
    mem_chunk_size = config_store.instance().get_value( ...
        'hor_config','mem_chunk_size');
end

isfb = num_pixels > scale_fac*mem_chunk_size;
