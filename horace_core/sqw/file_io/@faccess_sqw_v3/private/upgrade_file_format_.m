function  new_obj = upgrade_file_format_(obj,pix_range)
% Upgrade file from format 3 to the preferred file format
%
% currently preferred is format v 3.3
%
%
if ~exist('pix_range','var')
    pix_range = [];
end

new_obj = sqw_formats_factory.instance().get_pref_access();
if ischar(obj.num_dim) % source object is not initiated. Just return
    return
end

[new_obj,missing] = new_obj.copy_contents(obj);
if isempty(missing) % source and target are the same class. Invoke copy constructor only
    return;
end
[~,acc] = fopen(obj.file_id_);
if ~ismember(acc,{'wb+','rb+'})
    clear new_obj.file_closer_;  % as file is closed on output of reopen to write
    new_obj = new_obj.fclose();  % in case the previous does not work, and if it does, makes no harm
    new_obj = new_obj.set_file_to_update();
end
%
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

new_obj = new_obj.put_app_header();
new_obj = new_obj.put_sqw_footer();

if clear_sqw_holder
    new_obj.sqw_holder_ = [];
end

