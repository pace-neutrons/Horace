function  new_obj = upgrade_file_format_(obj)
% Upgrade file from format 3.2 to the preferred file format
%
% currently preferred is format v 3.21 for indirect instruments
%
%
%
%
%
new_obj = sqw_formats_factory.instance().get_pref_access('sqw2');
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
%
if isempty(obj.sqw_holder_)
    data = obj.get_data('-nopix');
else
    pix = obj.sqw_holder_.data.pix;
    if any(any(pix.pix_range == PixelData.EMPTY_RANGE_))
        pix.recalc_pix_range();
    end    
end

new_obj.pix_range_ = pix.pix_range;
new_obj.sqw_holder_ = data;
new_obj = new_obj.put_app_header();
new_obj = new_obj.put_sqw_footer();




