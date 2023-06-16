function dout = compact(din)
% Squeezes the data range in a dnd object to eliminate empty bins
%
% Syntax:
%   >> dout = compact(din)
%
% Input:
% ------
%   din         Input object
%
% Output:
% -------
%   dout        Output object, with length of axes reduced to yield the
%               smallest cuboid that contains the non-empty bins.
%

%Loop over the number of input objects:
for n = 1:numel(din)

    % Dimension of input data structure
    ndim = length(din(n).p);
    if ndim == 0  % no compacting needs to be done
        dout(n) = din(n);
        continue;
    end

    % Get section parameters and axis arrays:
    [val, irange] = data_bin_limits(din);


    new_bins = irange(2, :) - irange(1, :) + 1;
    new_step = (val(2, :) - val(1, :)) ./ new_bins;
    new_dims = find(new_bins > 1);
    nd = numel(new_dims);

    new_binning = cell(4, 1);
    new_img_range = zeros(2, 4);
    for i = 1:4
        new_img_range(:, i) = [val(1, i), val(2, i)];
        if new_bins(i) > 1
            new_binning{i} = [val(1, i) + new_step(i) / 2, new_step(i), val(2, i) - new_step(i) / 2];
        else
            new_binning{i} = [val(1, i), val(2, i)];
        end
    end

    array_section = cell(1, ndim);
    for i = 1:ndim
        array_section{i} = irange(1, i):irange(2, i);
    end

    switch nd
      case 0
        cls = @d0d;
      case 1
        cls = @d1d;
      case 2
        cls = @d2d;
      case 3
        cls = @d3d;
      case 4
        cls = @d4d;
    end

    new_dnd = cls(ortho_axes(new_binning{:}, ...
                             'ulen', din(n).axes.ulen, ...
                             'img_range', new_img_range), ...
                  din(n).proj);

    new_dnd.filepath = din(n).filepath;
    new_dnd.filename = din(n).filename;
    new_dnd.title = din(n).title;
    new_dnd.label = din(n).label;


    % Section signal, variance and npix arrays
    new_dnd.npix(:) = din(n).npix(array_section{:});
    new_dnd.s(:) = din(n).s(array_section{:});
    new_dnd.e(:) = din(n).e(array_section{:});

    dout(n) = new_dnd;
end

end
