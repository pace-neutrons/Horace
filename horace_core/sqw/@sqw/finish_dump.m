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
    % modify resulting object to contain the name of this file.
    obj.full_filename = page_op.outfile;
    out_blocks = {'bl__main_header';'bl_data_metadata';'bl_pix_metadata'};
else % probably will be tmp file, but pixels still should contain correct filname
    obj.pix.full_filename = wh.write_file_name;
    out_blocks  = {'bl_pix_metadata'};
end

pix = obj.pix;
% finish writing pix_data but do not store pix_metadata
pix_meta = wh.finish_pix_dump(pix,false);
pix.metadata = pix_meta;
% Get information necessary for storing the remaining data and initialize
% IO operations to store other changed parts of sqw object,
% do not close sqw_ldr handles
sqw_ldr = wh.release_pixinit_info(true);

% Prepare storing modifications to experiment
if page_op.exp_modified
    if isempty(out_blocks)
        out_blocks = {out_blocks(:);'bl__main_header'};
    end
    if page_op.exp_modified
        out_blocks = [out_blocks(:);{'bl_experiment_info_instruments';...
            'bl_experiment_info_samples';'bl_experiment_info_expdata'}];
    end
end
%  Check if image was modified and prepare storing changes to image
if ~page_op.changes_pix_only
    out_blocks = [out_blocks(:);'bl_data_nd_data'];
end
% Store all changes in target sqw file
obj.pix_ = pix;
sqw_ldr  = sqw_ldr.put_new_blocks_values(obj,'update',out_blocks);

set_as_tmp_obj = false;
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
            obj.full_filename = targ_filename;
        end
    end
    if page_op.init_filebacked_output
        sqw_ldr.full_filename = targ_filename;
        sqw_ldr = sqw_ldr.activate();
    end
else
    if wh.is_tmp_file && page_op.init_filebacked_output
        % this will also set obj.full_filename to be wh.write_file_name
        % until TmpFileHandler is there and will leave the parts of the
        % original (permanent) file name and path within the sqw object
        % hidden from access from sqw object
        set_as_tmp_obj = true;
    else
        obj.tmp_file_holder_ = [];
        obj.full_filename = sqw_ldr.full_filename;
    end
    % otherwise, write have occured into the target file and filename
    % have been already modified and stored in target file
end
%
if page_op.init_filebacked_output
    obj.pix = pix.init(sqw_ldr);
    if set_as_tmp_obj % needs to happens after pixels are initialized
        %
        obj = obj.set_as_tmp_obj(wh.write_file_name);
    end
else
    obj.pix  = [];
end
sqw_ldr.delete();
