function recalc_pix_range(obj)
% Recalculate pixels range in the situations, where the
% range for some reason appeared to be missing (i.e. loading pixels from
% old style files) or changed through private interface (for efficiency)
% and the internal integrity of the object has been violated.
%

obj.set_range(obj.EMPTY_RANGE_);
obj.reset_changed_coord_range('coordinates');
if obj.has_more
    hc = hor_config;
    ll = hc.log_level;
    while obj.has_more
        [current_page_num,total_num_pages]=obj.avance();
        if ll>0
            fprint('*** Processing page %d/%d\n',...
                current_page_num,total_num_pages);
        end
        obj.reset_changed_coord_range('coordinates');
    end
    
end

