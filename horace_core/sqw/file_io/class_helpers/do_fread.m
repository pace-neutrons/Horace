function A = do_fread(fid, varargin)
%%DO_FREAD Call Matlab's fread and throw an error if something goes wrong
% See help for builtin 'fread' for argument descriptions.
%
[fid, sizeA, precision, skip, machineformat] = parse_args(fid, varargin{:});

[A, vals_read] = fread(fid, sizeA, precision, skip, machineformat);
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


% -----------------------------------------------------------------------------
function [fid, sizeA, precision, skip, machineformat] = parse_args(varargin)
    parser = inputParser();
    % Leave 'fread' to validate most of the args later
    parser.addRequired('fid');
    parser.addOptional('sizeA', Inf);
    % we must add @ischar validator so arg is not mistaken for keyword argument
    parser.addOptional('precision', 'uint8=>double', @ischar);
    parser.addOptional('skip', 0);
    parser.addOptional('machineformat', 'n', @ischar);
    parser.parse(varargin{:});

    fid = parser.Results.fid;
    sizeA = parser.Results.sizeA;
    precision = parser.Results.precision;
    skip = parser.Results.skip;
    machineformat = parser.Results.machineformat;
end
