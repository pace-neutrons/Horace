function validate_ranges(starts, ends)
%%VALIDATE_RANGES ensure the given start and end indices are valid ranges
% This function validates that the given starts and ends form valid ranges.
% We check that the inputs have equal size, are vectors and that, for all i,
% starts(i) <= ends(i).
%
%
if any(size(starts) ~= size(ends))
    error( 'HORACE:validate_ranges:invalid_range', ...
           'Input arrays must have equal size, found [%s] and [%s].', ...
           num2str(size(starts)), num2str(size(ends)) ...
    );
elseif ~isvector(starts)
    error( 'HORACE:validate_ranges:invalid_range', ...
        'Input arrays must be vectors, found size [%s].', ...
        num2str(size(starts)) ...
    );
elseif any(starts > ends)
    error('HORACE:validate_ranges:invalid_range', 'Invalid ranges, not all starts(i) <= ends(i).');
end

end
