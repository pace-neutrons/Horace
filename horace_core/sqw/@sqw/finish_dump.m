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
    % the operations were performed into specific file and we want to
    % modify resutling object to contain the name of this file.
    obj.full_filename = page_op.outfile;
end

pix = obj.pix;
wh.finish_pix_dump(pix);
% Get information necessary for storing the remaining data and initialize
% following pixel IO operations, do not close sqw_ldr handles
sqw_ldr = wh.release_pixinit_info(true);

% Store modifications to image. Better implementation after Re #1319
sqw_ldr  = sqw_ldr.put_main_header(obj.main_header);
if page_op.old_file_format
    sqw_ldr   = sqw_ldr.put_headers(obj.experiment_info);
end
sqw_ldr  = sqw_ldr.put_dnd_data(obj.data);
if wh.move_to_original
    % this will close opened wh, and allow file moving
    sqw_ldr = sqw_ldr.deactivate();
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
            targ_filename = source_filename;
            obj.full_file_name = targ_filename;
        end
    end
    sqw_ldr.full_filename = targ_filename;
    sqw_ldr = sqw_ldr.activate();
else
    if wh.is_tmp_file
        % this will also set obj.full_filename to be wh.write_file_name
        % until TmpFileHandler is there and will leave the parts of the
        % original (permanent) file name and path within the sqw object
        % hidden from access from sqw object
        obj = obj.set_as_tmp_obj(wh.write_file_name);
    end
    % otherwise, write have occured into the target file and filename
    % have been already modified and stored in target file
end
%
obj.pix = pix.init(sqw_ldr);
