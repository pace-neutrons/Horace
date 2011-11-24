function sel = retain_for_fit (x, zarr, earr, xkeep, xremove, mask)
% RETAIN_FOR_FIT - selects data for fitting. Works with an arbitrary number
% of dimensions
%
% Returns array containing points that
% (1) have non-zero, positive, finite error bars
% (2) finite y values (i.e. remove NaN, -Inf, Inf)
% (3) whose x-values lie in the ranges to be retained that are
%     defined by xkeep and xremove and a mask array.
%
%    >> sel = retain_for_fit (x, y, e, xkeep, xremove, mask)
%
% Each y value is located in an n-dimensional space at points defined by
% co-ordinates x{1}(p), x{2}(p), x{3}(p), ... x{n}(p)
%
% Input:
% ======
%
%   x       A cell array of length n, where x{i} gives the coordinates in the
%           ith dimension for all the data points. The arrays can have any
%           size, but they must all have the same size.
%
%   y       Array containing the data values. Has the same size as any one of the x{i}
%
%   e       Array containng the corresponding error bars
%
%   xkeep   Ranges of x to retain for fitting. A range is specified by an array
%           of numbers which define a hypercube.
%           For example in case of two dimensions:
%               [xlo, xhi, ylo, yhi]
%           or in the case of n-dimensions:
%               [x1_lo, x1_hi, x2_lo, x2_hi,..., xn_lo, xn_hi]
%
%           More than one range can be defined in rows,
%               [Range_1; Range_2; Range_3;...; Range_m]
%             where each of the ranges are given in the format above.
%
%  xremove  Ranges to remove from fitting. Follows the same
%           format as xkeep.
%
%           If a point appears within both xkeep and xremove, then it will
%           be removed from the fit i.e. xremove takes precendence over xkeep. 
%
%   mask    Array of ones and zeros, with the same number of elements as the data
%           array, that indicates which of the data points are to be retained for
%           fitting

ndim = length(x);

% Find data points with finite x, z values and positive, non-zero, finite error bars
% -----------------------------------------------------------------------------------
% Get points whose x values that are finite
ok_xvals = true(size(x{1}));
for i = 1:ndim
    ok_xvals = isfinite(x{i}) & ok_xvals;
end
if ~any(ok_xvals)
    disp (['All points have at least one undefined (infinite or NaN) coordinate value'])
    sel = false(size(x{i}));
    return
elseif ~all(ok_xvals)
    disp ('Points with at least one undefined (infinite or NaN) coordinate value have been removed')
end

% Remove data points with non-finite z values
ok_zvals = isfinite(zarr);
if ~any(ok_zvals)
    disp ('All points have undefined (infinite or NaN) data values')
    sel = false(size(zarr));
    return
elseif ~all(ok_zvals)
    disp ('Points with undefined (infinite or NaN) data values have been removed from fit')
end

% Remove data points with zero or negative error bars
ok_ebars = isfinite(earr) & earr>0;
if ~any(ok_ebars)
    disp ('All points have zero, negative or undefined (infinite or NaN) error bars')
    sel = false(size(x{1}));
    return
elseif ~all(ok_ebars)
    disp ('Points with zero, negative or undefined (infinite or NaN) error bars have been removed from fit')
end

ok_data = ok_xvals & ok_zvals & ok_ebars;
if ~any(ok_data)
    disp('All points have either non-finite coordinate or data values, or non-finite, zero or negative error bars')
    sel = false(size(x{1}));
    return
end

% Remove data from outside selected ranges
% ----------------------------------------
if ~isempty(xkeep) || ~isempty(xremove) || ~isempty(mask) % one or more of keep range, remove range and mask is provided
    % look at keep range
    if ~isempty(xkeep)
        if size(xkeep,2)/2~=ndim || length(size(xkeep))~=2
            error(['xkeep must be a numeric array of size r x 2n, where n=number of dimensions (n=',num2str(ndim),')'])
        end
        keep_range = false(size(x{1}));
        for i = 1:size(xkeep,1)        % find each given "box" in turn
            range_current = true(size(x{1}));
            for j = 1:length(x)           % look at each dimension and make sure the indexes are within all axes
                range_current = (x{j} >= min([xkeep(i,2*j-1) xkeep(i,2*j)]) &...
                    x{j} <= max([xkeep(i,2*j-1) xkeep(i,2*j)])) & range_current;
            end
            keep_range = keep_range | range_current;     % "overlap" the boxes
        end
        if ~any(keep_range)
            disp ('There are no points within the range(s) specified to be retained')
            sel = false(size(x{1}));
            return
        end
    else
        keep_range = true(size(zarr));
    end

    % look at remove range
    if ~isempty(xremove)
        if size(xremove,2)/2~=ndim || length(size(xremove))~=2
            error(['xremove must be a numeric array of size r x 2n, where n=number of dimensions (n=',num2str(ndim),')'])
        end
        remove_range = false(size(x{1}));
        for i = 1:size(xremove,1)        % find each given "box" in turn
            range_current = true(size(x{1}));
            for j = 1:length(x)           % look at each dimension and make sure the indexes are within all axes
                range_current = (x{j} >= min([xremove(i,2*j-1) xremove(i,2*j)]) &...
                    x{j} <= max([xremove(i,2*j-1) xremove(i,2*j)])) & range_current;
            end
            remove_range = remove_range | range_current;     % "overlap" the boxes
        end
        if all(remove_range)
            disp ('All points have been eliminated by the range(s) specified to be removed')
            sel = false(size(x{1}));
            return
        end
    else
        remove_range = false(size(zarr));
    end
    
    % Check mask array
    if ~isempty(mask)
        if numel(mask)~=numel(zarr)
            error ('Mask array must be numeric or logical array with same number of elements as data array')
        end
        mask = reshape(mask,size(zarr));
    else
        mask = true(size(zarr));
    end

    % put together remove and keep ranges
    ok_range = keep_range & ~remove_range & mask;
    if ~any(ok_range)
        disp ('No points lie inside the accepted range(s)')
        sel = false(size(zarr));
        return
    end

else
    ok_range = true(size(zarr));
end

% Get final list of points to fit
sel = ok_data & ok_range;
if ~any(sel)
    disp ('No points left to fit')
end
