function A = do_fread(fid, varargin)
%%DO_FREAD Call Matlab's fread and throw an error if something goes wrong
% See help for builtin 'fread' for argument descriptions.
%
if nargin >= 2
    sizeA = varargin{1};
end

[A, vals_read] = fread(fid, varargin{:});
[mess, err_code] = ferror(fid);

eof_file_req = any(sizeA == Inf);
if ~eof_file_req && vals_read ~= prod(sizeA)
    error('HORACE:do_fread', 'Expected to read %i values, %i read.', ...
          prod(sizeA), vals_read);
end

eof_reached = (err_code == -4);
if err_code ~= 0 && (eof_reached && ~eof_file_req)
    error('HORACE:do_fread', mess);
end

end
