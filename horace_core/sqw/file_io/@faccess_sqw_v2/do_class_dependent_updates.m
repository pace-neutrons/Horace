function new_obj = do_class_dependent_updates(obj,new_obj)
% do modifications, necessary to upgrade file format 2 to file format 3.3

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
        new_obj.sqw_holder_.pix = PixelData(obj,pix_page_size);
    else
        % load everything in memory
        new_obj.sqw_holder_.pix = PixelData(obj);
    end
    clear_sqw_holder = true; %

end
new_obj = new_obj.init_v3_specific();
%
new_obj = new_obj.put_instruments(); % this also upgrades (saves) sqw footer
% using sqw_holder_

if clear_sqw_holder
    new_obj.sqw_holder_ = [];
end
