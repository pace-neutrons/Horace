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
pix = obj.pix;

wh = wh.put_sqw(obj,'-hold_pix_place');
%obj.full_filename = wh.full_filename;
wh = wh.put_pix_metadata(pix);
% Force pixel update. TODO: Is this necessary?
wh = wh.put_num_pixels(pix.num_pixels);

%=========================================================================
% retrieve information, necessary for memmapfile initialization
offset   = wh.pix_position;
tail = wh.eof_position-wh.pixel_data_end;
targ_filename = wh.full_filename;
wh.delete();
%
if ~isempty(tmp_fl_holder) && ~isempty(tmp_fl_holder.move_to_file)
    % clear memmapfile accessor from the source file to be overwritten
    pix = pix.delete();
    obj.pix = pix;

    ok = movefile(targ_filename,tmp_fl_holder.move_to_file,'f');
    if ~ok
        del_memmapfile_files(tmp_fl_holder.move_to_file)
    end
    ok =movefile(targ_filename,tmp_fl_holder.move_to_file,'f');
    if ok
        targ_filename = tmp_fl_holder.move_to_file;
    else
        warning('HORACE:file_access', ...
            ['Can not move temporary file: %s into the file requested: %s\n' ...
            'sqw object remains build over temporary file'], ...
            tmp_fl_holder.file_name,tmp_fl_holder.move_to_file);
        targ_filename = tmp_fl_holder.file_name;
    end
end

f_accessor = memmapfile(targ_filename, ...
    'Format', pix.get_memmap_format(tail), ...
    'Repeat', 1, ...
    'Writable', true, ...
    'Offset', offset);

%
obj.pix = pix.init(f_accessor);

obj.full_filename = targ_filename;
