function obj = recalc_pix_range(obj)
% Recalculate pixels range in the situations, where the
% range for some reason appeared to be missing (i.e. loading pixels from
% old style files) or changed through private interface (for efficiency)
% and the internal integrity of the object has been violated.
%
% returns obj for compatibility with recalc_pix_range method of
% combine_pixel_info class, which may be used instead of PixelData
% for the same purpose.
% recalc_pix_range is a normal Matlab value object (not a handle object),
% returning its changes in LHS
%
obj.move_to_first_page();
obj.load_current_page_if_data_empty_();
obj.set_range(obj.EMPTY_RANGE_);
obj.reset_changed_coord_range('coordinates');
if obj.has_more
    ic = 1;
    dev = 10;
    hc = hor_config;
    ll = hc.log_level;
    while obj.has_more
        [current_page_num,total_num_pages] = obj.advance();
        ic = ic+1;
        if ll>0 && ic>=dev
            ic = 0;
            fprintf( ...
                '*** Processing page #%d/of#%d\n', ...
                current_page_num, ...
                total_num_pages ...
                );
        end
        obj.reset_changed_coord_range('coordinates');
    end
end
