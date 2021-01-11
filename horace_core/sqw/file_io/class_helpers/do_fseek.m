function status = do_fseek(fid, offset, origin)
%%DO_SEEK Call fseek with the given arguments, throw an error if something goes wrong
% See help for 'fseek' for argument descriptions
%
status = fseek(fid, offset, origin);
if status ~= 0
    [mess, ~] = ferror(fid);
    error('SQW_BINFILE_COMMON:get_pix_at_indices', ...
          'Cannot move to requested position in file:\n  %s', ...
          mess);
end
