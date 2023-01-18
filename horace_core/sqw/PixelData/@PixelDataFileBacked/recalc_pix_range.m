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

obj.set_range(obj.EMPTY_RANGE_);
ll = get(hor_config, 'log_level');
if ll > 0
    display_every_nth_iteration = 10;
else
    display_every_nth_iteration = obj.n_pages;
end

for lp = 0:display_every_nth_iteration:obj.n_pages
    to_do = min(obj.n_pages - lp, display_every_nth_iteration);
    for i = 1:to_do
        obj.move_to_page(lp+i);
        obj.reset_changed_coord_range('coordinates');
    end

    if ll > 0
        fprintf('*** Processing page #%d of #%d \n', lp+display_every_nth_iteration, obj.n_pages);
    end

end

end
