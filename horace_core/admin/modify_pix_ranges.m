function modify_pix_ranges(filenames,varargin)
% Helper function to update pixel ranges stored in old binary sqw files
% (version below 3.2 stored by Horace 3.5 and earlier)
% to the values, used by Horace 3.6 and later.
%
% The file format is upgraded from version 3.1 or 2.0 into version 3.3
% version 3.2 is not currently upgradable
%
% Input:
% filenames -- filename or list of filenames, describing full path to
%              binary sqw files to change
% Optional:
% use_urange -- if provided, use image range stored within the file
%               (urange in old file formats).to specify pixel range.
%
% Image range is equal to pixel range for newly generated sqw files.
% for cuts it is not correct.
%
%
% Result:
% The file format of the provided files is updated to version 3.3.
% The pixel ranges of the input sqw files are calculated and stored with
% old files in-place.
%
[ok,mess,use_urange] = parse_char_options(varargin,{'use_urange'});
if ~ok
    error('MODIFY_PIX_RANGE:invalid_argument',mess);
end

loaders = get_loaders(filenames);
n_inputs = numel(loaders);
%
for i=1:n_inputs
    if ~loaders{i}.sqw_type
        error('SQW_FILE_IO:invalid_argument',...
            'read_horace: File %s contans dnd information but only sqw file requested',...
            fullfile(loaders{i}.filepath,loaders{i}.filename));
    end
end
hc = hor_config;
dts = hc.get_data_to_store();
clob = onCleanup(@()set(hc,dts));
hc.saveable = false;
log_level = hc.log_level;
hc.pixel_page_size = hc.mem_chunk_size*9*4;

for i=1:n_inputs
    ld = loaders{i};
    new_format = strcmpi(ld.file_version,'-v3.3');
    if new_format && ~use_urange
        if log_level>0
            fprintf(2,' file %s is already updated to the recent version\n',ld.filename);
        end
        continue
    end
    % set up constant blocks map which allows rewriting blocks,
    % having permanent location within the file
    if new_format
        ld = ld.reopen_to_write();
    else
        ld = ld.set_file_to_update(fullfile(ld.filepath,ld.filename));
        ld = ld.upgrade_file_format();
    end
    if use_urange
        pix_range = ld.get_img_db_range();
    else
        data = ld.get_data();
        data.pix.recalc_pix_range();
        pix_range = data.pix.pix_range;
    end
    ld = ld.store_pix_range(pix_range);
    %ld = ld.put_sqw_footer();
    ld.delete();
end
hc.saveable = true;
