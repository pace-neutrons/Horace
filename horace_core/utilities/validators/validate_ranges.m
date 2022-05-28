function [ok, mess] = validate_ranges(starts, bl_sizes)
%%VALIDATE_RANGES ensure the given start and end indices are valid ranges
% This function validates that the given starts and ends form valid ranges.
% We check that the inputs have equal size, are vectors and that, for all i,
% starts(i) <= ends(i).
%
%
mess = '';
if any(size(starts) ~= size(bl_sizes))
    mess = sprintf( ...
        'Input arrays must have equal size, found [%s] and [%s].', ...
        num2str(size(starts)), num2str(size(bl_sizes)) ...
    );
elseif ~isvector(starts)
    mess = sprintf( ...
        'Input arrays must be vectors, found size [%s].', ...
        num2str(size(starts)) ...
    );
elseif any(bl_sizes<=0)
    mess = 'Invalid ranges, not all starts(i) <= ends(i).';
end

ok = isempty(mess);
