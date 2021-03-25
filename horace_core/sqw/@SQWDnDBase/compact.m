function wout = compact (win)
% Squeezes the data range in an sqw or dnd object to eliminate empty bins
%
% Syntax:
%   >> wout = compact(win)
%
% Input:
% ------
%   win         Input object
%
% Output:
% -------
%   wout        Output object, with length of axes reduced to yield the
%               smallest cuboid that contains the non-empty bins.
%

% Initialise output argument
wout = copy(win);

%Loop over the number of inputs objects:
for n = 1:numel(win)

    % Dimension of input data structure
    ndim = length(win(n).data_.p);
    if ndim == 0  % no compacting needs to be done
        return
    end

    % Get section parameters and axis arrays:
    [val, irange] = data_bin_limits(win(n).data_);

    array_section = cell(1, ndim);
    for i = 1:ndim
        wout(n).data_.p{i} = win(n).data_.p{i}(irange(1, i):irange(2, i) + 1);
        array_section{i} = irange(1, i):irange(2, i);
    end

    % Section signal, variance and npix arrays
    wout(n).data_.s = win(n).data_.s(array_section{:});
    wout(n).data_.e = win(n).data_.e(array_section{:});
    wout(n).data_.npix = win(n).data_.npix(array_section{:});
end
