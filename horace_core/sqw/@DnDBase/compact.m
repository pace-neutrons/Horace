function dout = compact(din)
% Squeezes the data range in a dnd object to eliminate empty bins on
% borders
%
% Particularly of use for contracting dnds for plotting
%
% If an array of DnDs is provided, this will return a cell array
% otherwise it will return a DnD scalar
%
% An equivalent method is provided for the sqw class to compact its
% dnd sub-objects
%
% Syntax:
%   >> dout = compact(din)
%
% Input:
% ------
%   din         Array of input object(s)
%
% Output:
% -------
%   dout       Scalar output object or cell array of output object(s), with length
%              of axes reduced to yield the smallest cuboid for each input object
%              that contains the non-empty bins.

dout = cell(numel(din), 1);

%Loop over the number of input objects:
for n = 1:numel(din)

    % Dimension of input data structure
    ndim = length(din(n).p);
    if ndim == 0  % no compacting needs to be done
        dout{n} = din(n);
        continue;
    end

    % Get section parameters and axis arrays:
    [val, irange] = data_bin_limits(din);
    args = num2cell(val', 2);
    dout{n} = din.section(args{:});
end

if isscalar(dout)
    dout = dout{1};
end


end
