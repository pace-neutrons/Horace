function validate_ranges(starts, bl_sizes)
%%VALIDATE_RANGES ensure the given start and end indices are valid ranges
% This function validates that the given starts and block sizes form valid ranges.
% We check that the inputs have equal size, are vectors and that, for all i,
% block_sizes(i) > 0
%
%
if any(size(starts) ~= size(bl_sizes))
    error( 'HORACE:validate_ranges:invalid_range', ...
           'Input arrays must have equal size, found [%s] and [%s].', ...
           num2str(size(starts)), num2str(size(bl_sizes)) ...
    );
elseif ~isvector(starts)
    error( 'HORACE:validate_ranges:invalid_range', ...
        'Input arrays must be vectors, found size [%s].', ...
        num2str(size(starts)) ...
    );
elseif any(bl_sizes <= 0)
    error('HORACE:validate_ranges:invalid_range', 'Invalid ranges, not all blocks(i) > 0.');
end

end
