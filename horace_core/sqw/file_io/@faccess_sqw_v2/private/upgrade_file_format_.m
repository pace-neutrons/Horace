function  new_obj = upgrade_file_format_(obj)
% Upgrade file from format 3 to the preferred file format
%
% currently preferred is format v 3.3
%
%

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
% file format 3 specific part---------------------------------------------
clear_sqw_holder=false;
if isempty(new_obj.sqw_holder_) % all file positions except instrument and sample
    % are already defined so we need just nominal object with instrument and sample
    nf = new_obj.num_contrib_files();
    % make pseudo-sqw  with instrument and sample
    new_obj.sqw_holder_ = obj.make_pseudo_sqw(nf);
    % check pixel page size to deploy file-based operations if necessary
    % TODO: modify this to direct filebased algorithm when refactoring is
    % done.
    hc = hor_config;
    mem          = sys_memory();
    pix_page_size    = hc.pixel_page_size;
    ll           = hc.log_level;
    crit = min(0.6*mem,6*pix_page_size); % TODO: is this rule well justified?

    if obj.npixels*sqw_binfile_common.FILE_PIX_SIZE > crit
        if ll>0
            fprintf(['*** Upgrading file format to a latest binary version.\n',...
                '    This is once per-old file long operation, analysing the whole pixels array\n'])
        end
        % Load the .sqw file using the sqw constructor so that we can pass the
        % pixel_page_size argument to get an sqw with file-backed pixels.
        new_obj.sqw_holder_.pix = PixelDataBase.create(obj,pix_page_size);
    else
        % load everything in memory
        new_obj.sqw_holder_.pix = PixelDataBase.create(obj);
    end
    clear_sqw_holder = true; %

end
new_obj = new_obj.init_v3_specific();
%
new_obj = new_obj.put_app_header();
new_obj = new_obj.put_instruments(); % this also upgrades (saves) sqw footer


if clear_sqw_holder
    new_obj.sqw_holder_ = [];
end


