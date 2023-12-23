function wh = get_write_handle(obj, outfile,outfile_defned)
% Unlock write access to filebacked sqw object and obtain handle to
% the class-helper to write pixel data to binary file
%
% Does nothing for memory based object.
%
% Optional input:
% outfile  -- target sqw file will be created with the filename provided
%             If missing, the file will have random temporary filename
% outfile_defned
%          -- if provided and true, do not generate tmp filename for
%             operation but ise the provided one
%
if ~obj.pix.is_filebacked
    wh = [];
    return;
end
if nargin == 1
    outfile = '';
end
if nargin <3
    outfile_defned = false;
end

if outfile_defned
    op_outfile = outfile;
    move_to_original = false;
else
    [op_outfile,move_to_original] = PixelDataBase.build_op_filename( ...
        obj.pix.full_filename,outfile);
end

% Write the given SQW object to the given file.
% The pixels of the SQW object will be derived from the image signal array
% and npix array, saving in chunks so they do not need to be held in memory.
ldr = sqw_formats_factory.instance().get_pref_access(obj);
ldr = ldr.init(obj, op_outfile);
ldr = ldr.put_sqw('-hold_pix_place');
wh  = pix_write_handle(ldr);
wh.move_to_original = move_to_original;
end
