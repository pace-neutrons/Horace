function new_obj = do_class_dependent_updates(obj,new_obj,pix_range)
% Method does class dependent changes while updating from sqw file format
% v3.2 to file format version 3.21

if ~exist('pix_range','var')
    pix_range = [];
end

clear_sqw_holder = false;
if isempty(obj.sqw_holder_)
    clear_sqw_holder = true;
    % all file positions except instrument and sample
    % are already defined so we need just nominal object with instrument and sample
    nf = new_obj.num_contrib_files();
    % make pseudo-sqw  with instrument and sample
    new_obj.sqw_holder_ = obj.make_pseudo_sqw(nf);
    data = obj.get_data();
    pix = obj.get_pix();
    if ~isempty(pix_range)
        pix.set_range(pix_range);
    end
    new_obj.sqw_holder_.data = data;
    new_obj.sqw_holder_.pix = pix;

else
    pix = obj.sqw_holder_.pix;
end
%
if any(any(pix.pix_range == PixelData.EMPTY_RANGE_))
    pix.recalc_pix_range();
end


new_obj.pix_range_ = pix.pix_range;
new_obj = new_obj.put_sqw_footer();

if clear_sqw_holder
    new_obj.sqw_holder_ = [];
end
