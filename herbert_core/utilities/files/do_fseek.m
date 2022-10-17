function status = do_fseek(fid, offset, origin)
%%DO_SEEK Call do_fseek with the given arguments, throw an error if something goes wrong
% See help for 'do_fseek' for argument descriptions
%
try
    status = fseek(fid, offset, origin);
catch ME
    rethrow(ME)
end
if status ~= 0
    [mess, ~] = ferror(fid);
    error('SQW_BINFILE_COMMON:get_pix_at_indices', ...
          'Cannot move to requested position in file:\n  %s', ...
          mess);
end
