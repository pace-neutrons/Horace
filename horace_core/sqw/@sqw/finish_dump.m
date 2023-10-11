function obj = finish_dump(obj,page_op)
% Complete filebacked operation on sqw object
% page_op -- will be used in a future to provide
%            list of modified sqw fields to save
%            usually operation specific list of sqw object fields
%            Re #1319

[wh,~,obj.pix] = obj.pix.get_write_info(true);
if isempty(wh)
    return;
end
tmp_fl_holder = obj.file_holder_;
if ~isa(wh,'sqw_file_interface')
    error('HORACE:sqw:runtime_error', ...
        'dump can be finished using file accessor only');
end
source_filename = wh.full_filename;
if ~isempty(tmp_fl_holder) && ~isempty(tmp_fl_holder.move_to_file)
    targ_filename = tmp_fl_holder.move_to_file;
    change_target_fn = true; % we want target file name to be different from the one,
    % writing was performed
else
    change_target_fn = false;
    targ_filename = source_filename;
end
obj.full_filename = targ_filename;

pix = obj.pix;

% Store modifications. Better implementation after Re #1319
wh = wh.put_main_header(obj.main_header);
if page_op.old_file_format
    wh = wh.put_headers(obj.experiment_info);
end
wh = wh.put_dnd_data(obj.data);
%
wh = wh.put_pix_metadata(pix);
% Force pixel update. TODO: Is this necessary?
wh = wh.put_num_pixels(pix.num_pixels);

%=========================================================================
% retrieve information, necessary for memmapfile initialization
offset   = wh.pix_position;
tail = wh.eof_position-wh.pixel_data_end;
wh.delete();
%
if change_target_fn
    % clear memmapfile accessor from the source file to be overwritten
    pix = pix.delete();
    obj.pix = pix;

    ok = movefile(source_filename,targ_filename,'f');
    if ~ok
        del_memmapfile_files(targ_filename)
        ok =movefile(source_filename,targ_filename,'f');
        if ~ok
            warning('HORACE:file_access', ...
                ['Can not move temporary file: %s into the file requested: %s\n' ...
                'sqw object remains build over temporary file'], ...
                tmp_fl_holder.file_name,targ_filename);
            targ_filename = tmp_fl_holder.file_name;
        end
    end
end

f_accessor = memmapfile(targ_filename, ...
    'Format', pix.get_memmap_format(tail,true), ...
    'Repeat', 1, ...
    'Writable', true, ...
    'Offset', offset);
%
obj.pix = pix.init(f_accessor);
