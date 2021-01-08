function [ok, mess] = validate_ranges(starts, ends)
%%VALIDATE_RANGES ensure the given start and end indices are valid ranges
% This function validates that the given starts and ends form valid ranges.
% We check that the inputs have equal size, are vectors and that, for all i,
% starts(i) <= ends(i).
%
%
mess = '';
if any(size(starts) ~= size(ends))
    mess = sprintf( ...
        'Input arrays must have equal size, found [%s] and [%s].', ...
        num2str(size(starts)), num2str(size(ends)) ...
    );
elseif ~isvector(starts)
    mess = sprintf( ...
        'Input arrays must be vectors, found size [%s].', ...
        num2str(size(starts)) ...
    );
elseif any(starts > ends)
    mess = 'Invalid ranges, not all starts(i) <= ends(i).';
end

ok = isempty(mess);
