function [starts, lengths] = merge_ranges(starts, lengths)
% Merges cell arrays of intervals (defined as starts and lengths to read) into
% single block of starts, lengths eliminating overlap.

    if numel(starts) ~= numel(lengths) || ...
            ~isequal(cellfun(@numel, starts), cellfun(@numel, lengths))
        error('HERBERT:merge_ranges:invalid_arguments', ...
              'starts and lengths must be same shape, starts: [%s], lengths: [%s]', ...
             num2str(cellfun(@numel, starts)), num2str(cellfun(@numel, lengths)))
    end

    if numel(starts) == 1
        starts = starts{1};
        lengths = lengths{1};
        return
    end

    starts = horzcat(starts{:});
    lengths = horzcat(lengths{:});

    [starts, ix] = sort(starts);
    lengths = lengths(ix);

    ends = starts + lengths - 1;

    ind = 1;

    for i = 2:length(ends)

        if ends(ind) >= starts(i)-1
            ends(ind) = max(ends(ind), ends(i));
        else
            ind = ind + 1;
            starts(ind) = starts(i);
            ends(ind) = ends(i);
        end
    end

    starts = starts(1:ind);
    lengths = ends(1:ind) - starts + 1;

end
