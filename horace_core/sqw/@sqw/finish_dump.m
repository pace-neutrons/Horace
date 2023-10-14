function obj = finish_dump(obj,page_op)
% Complete filebacked operation on sqw object
% page_op -- Class which describes page operation, performed on the object
%            and contains the write handle, used to write data to the file
%
%            will be used in a future to provide
%            list of modified sqw fields to save
%            usually operation specific list of sqw object fields
%            Re #1319

wh = page_op.write_handle;
if isempty(wh)
    return;
end
if ~isempty(page_op.outfile)
    obj.full_file_name = page_op.outfile;
end

pix = obj.pix;


% Store modifications to image. Better implementation after Re #1319
wh = wh.put_main_header(obj.main_header);
if page_op.old_file_format
    wh = wh.put_headers(obj.experiment_info);
end
wh = wh.put_dnd_data(obj.data);
%

% this will close opened wh, and allow file moving
pix_init_info = wh.release_pixinit_info(pix);
if wh.move_to_original
    source_filename = wh.write_file_name;
    targ_filename   = page_op.outfile;
    ok = movefile(source_filename,targ_filename,'f');
    if ~ok
        del_memmapfile_files(targ_filename)
        ok =movefile(source_filename,targ_filename,'f');
        if ~ok
            warning('HORACE:file_access', ...
                ['Can not move temporary file: %s into the file requested: %s\n' ...
                'sqw object remains build over temporary file'], ...
                source_filename,targ_filename);
            obj.full_file_name = obj.write_file_name;
        end
    end
else
    % Set tmp file handler to result of operation
    if wh.is_tmp_file
        % this will also set obj.full_filename to be wh.write_file_name
        % until TmpFileHandler is there and will leave the parts of the
        % original (permanent) file name and path within the sqw object
        obj.tmp_file_handler = TmpFileHandler(wh.write_file_name,true);
    end
    % otherwise, write have occured into the target file and filename
    % have been already modified and stored in target file
end
%
obj.pix = pix.init(pix_init_info);
