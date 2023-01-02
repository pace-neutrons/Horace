function   new_obj = do_class_dependent_changes(obj,new_obj,pix_range)
% Method does class dependent changes while updating from sqw file
% format v3.1 to file format version 3.3

if ~exist('pix_range','var')
    pix_range = [];
end


% file format 3.3 specific part---------------------------------------------
clear_sqw_holder = false;
if isempty(new_obj.sqw_holder_) % all file positions except instrument and sample
    % are already defined so we need just nominal object with instrument and sample
    nf = new_obj.num_contrib_files();
    % make pseudo-sqw  with instrument and sample
    new_obj.sqw_holder_ = obj.make_pseudo_sqw(nf);
    clear_sqw_holder = true;
end

%
data = obj.get_data();
if isempty(pix_range)
    pix = obj.get_pix();
    if any(any(pix.pix_range == PixelData.EMPTY_RANGE_))
        pix.recalc_pix_range();
    end
else
    pix = obj.get_pix();
    pix.set_range(pix_range);
end
new_obj.sqw_holder_.data = data;
new_obj.pix_range_ = pix.pix_range;

new_obj = new_obj.put_sqw_footer();

if clear_sqw_holder
    new_obj.sqw_holder_ = [];
end
