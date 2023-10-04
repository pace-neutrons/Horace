function [obj, ldr] = get_new_handle(obj, outfile)
% Unlock write access to filebacked sqw object.
% Does nothing for memory based object.
%
% Optional input:
% outfile  -- target sqw file will be created with the filename provided
%             If missing, the file will have random temporary filename
%
if ~obj.pix.is_filebacked
    ldr = [];
    return;
end

if ~exist('outfile', 'var') || isempty(outfile)
    if isempty(obj.full_filename)
        obj.full_filename = 'in_mem';
    end
    obj.file_holder_ = TmpFileHandler(obj.full_filename);
    outfile = obj.file_holder_.file_name;
end

% Write the given SQW object to the given file.
% The pixels of the SQW object will be derived from the image signal array
% and npix array, saving in chunks so they do not need to be held in memory.
ldr = sqw_formats_factory.instance().get_pref_access(obj);
ldr = ldr.init(obj, outfile);
ldr = ldr.put_sqw('-hold_pix_place');
obj.pix = obj.pix.get_new_handle(ldr);
end
