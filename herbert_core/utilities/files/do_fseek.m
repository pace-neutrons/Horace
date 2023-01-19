function status = do_fseek(fid, offset, origin)
%%DO_FSEEK Call fseek with the given arguments, throw an error if something goes wrong
% See help for 'fseek' for argument descriptions
%
try
    status = fseek(fid, offset, origin);
catch ME
    rethrow(ME)
end
if status ~= 0
    [mess, ~] = ferror(fid);
    filename = fopen(fid);
    error('HORACE:utilities:do_fseek', ...
          'Cannot move to requested position in file (%s):\n  %s', ...
          filename, mess);
end
