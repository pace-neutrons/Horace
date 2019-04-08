function [msk,ok,mess] = mask_points_xye (x, xkeep, xremove, mask)
% Determine the points to keep on the basis of ranges and mask array.
% Does NOT find array elements with zero error bars, NaN data values etc.
%
%    >> [msk,ok,mess] = mask_points_xye (x, xkeep, xremove, mask)
%
% Input:
% ------
%   x       A cell array of length n, where x{i} gives the coordinates in the
%           ith dimension for all the data points. The arrays can have any
%           size, but they must all have the same size. This size is assumed to
%           be the same as the data array.
%
%   xkeep   Ranges of x to retain for fitting. A range is specified by an array
%           of numbers which define a hypercube.
%           For example in case of two dimensions:
%               [xlo, xhi, ylo, yhi]
%           or in the case of n-dimensions:
%               [x1_lo, x1_hi, x2_lo, x2_hi,..., xn_lo, xn_hi]
%
%              e.g. 1D: [50,70]
%                   2D: [1,2,130,160]
%
%           More than one range can be defined in rows,
%               [Range_1; Range_2; Range_3;...; Range_m]
%             where each of the ranges are given in the format above.
%
%           If empty, then ignored
%
%   xremove Ranges to remove from fitting. Follows the same
%           format as xkeep.
%
%           If a point appears within both xkeep and xremove, then it will
%           be removed from the fit i.e. xremove takes precendence over xkeep.
%
%   mask    Array of ones and zeros, with the same number of elements as the data
%           array, that indicates which of the data points are to be retained for
%           fitting (true to retain, false to ignore).
%
%           If empty, then ignored
%
% Output:
% -------
%   msk     Mask array of same shape as data. true for bins to keep, false to discard.
%
%   ok      =true if worked, =false if error
%
%   mess    messages: if ok=true then informational or warning, if ok=false then the error message


% Original author: T.G.Perring
%
% $Revision:: 830 ($Date:: 2019-04-08 17:54:30 +0100 (Mon, 8 Apr 2019) $)


% Remove data from outside selected ranges
% ----------------------------------------
if ~isempty(xkeep) || ~isempty(xremove) || ~isempty(mask) % one or more of keep range, remove range and mask is provided
    msk=false(0);
    ok=false;
    mess='';
    
    ndim = numel(x);
    
    % Look at keep range
    if ~isempty(xkeep)
        if ~isnumeric(xkeep) || size(xkeep,2)/2~=ndim || length(size(xkeep))~=2
            mess=['xkeep must be a numeric array of size r x 2n, where n=number of dimensions (n=',num2str(ndim),')'];
            return
        end
        keep_range = false(size(x{1}));
        for i = 1:size(xkeep,1)         % find each given "box" in turn
            range_current = true(size(x{1}));
            for j = 1:ndim              % look at each dimension and make sure the indexes are within all axes
                range_current = (x{j} >= min([xkeep(i,2*j-1) xkeep(i,2*j)]) &...
                    x{j} <= max([xkeep(i,2*j-1) xkeep(i,2*j)])) & range_current;
            end
            keep_range = keep_range | range_current;     % "overlap" the boxes
        end
        if ~any(keep_range)
            msk = false(size(x{1}));
            ok = true;
            mess='There are no points within the range(s) specified to be retained';
            return
        end
    else
        keep_range = true(size(x{1}));
    end
    
    % Look at remove range
    if ~isempty(xremove)
        if ~isnumeric(xremove) || size(xremove,2)/2~=ndim || length(size(xremove))~=2
            mess=['xremove must be a numeric array of size r x 2n, where n=number of dimensions (n=',num2str(ndim),')'];
            return
        end
        remove_range = false(size(x{1}));
        for i = 1:size(xremove,1)       % find each given "box" in turn
            range_current = true(size(x{1}));
            for j = 1:ndim              % look at each dimension and make sure the indexes are within all axes
                range_current = (x{j} >= min([xremove(i,2*j-1) xremove(i,2*j)]) &...
                    x{j} <= max([xremove(i,2*j-1) xremove(i,2*j)])) & range_current;
            end
            remove_range = remove_range | range_current;     % "overlap" the boxes
        end
        if all(remove_range)
            msk = false(size(x{1}));
            ok = true;
            mess='All points have been eliminated by the range(s) specified to be removed';
            return
        end
    else
        remove_range = false(size(x{1}));
    end
    
    % Check mask array
    if ~isempty(mask)
        if ~(isnumeric(mask)||islogical(mask)) || numel(mask)~=numel(x{1})
            mess='Mask array must be numeric or logical array with same number of elements as data array';
            return
        end
        mask = reshape(mask,size(x{1}));    % in case shape is wrong
        if ~any(mask)
            msk = false(size(x{1}));
            ok = true;
            mess='The input mask array masks all data points';
            return
        end
    else
        mask = true(size(x{1}));
    end
    
    % Put together remove and keep ranges
    msk = keep_range & ~remove_range & mask;
    ok = true;
    if ~any(msk)
        mess='There are no points left after applying the combined ''keep'', ''remove'' and ''mask'' input arguments';
    end
    
else
    msk = true(size(x{1}));
    ok = true;
    mess = '';
end
