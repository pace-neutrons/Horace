function [sel,ok,mess] = mask_for_fit_xye (x, y, e, mask)
% Create mask array that removes points that would cause a least-squares fit to fail.
%
%    >> sel = mask_for_fit_xye (x, y, e)
%    >> sel = mask_for_fit_xye (x, y, e, mask)
%
% Returns array containing points that
% (1) have non-zero, positive, finite error bars
% (2) finite y values (i.e. remove NaN, -Inf, Inf)
% (3) if x values are given, those which are finite
% Accumulates the masked points on top of an optional mask array.
% Bad points that are already masked are ignored, so no unnecessary
% warning mwessages are created.
%
% Input:
% ------
%   x       A cell array of length n, where x{i} gives the coordinates in the
%           ith dimension for all the data points. The arrays can have any
%           size, but they must all have the same size.
%           [if x is empty, then tests on x are ignored]
%
%   y       Array containing the data values. Has the same size as any one of the x{i}
%
%   e       Array containng the corresponding error bars
%           If give variances, this has the same effect (except that the function cannot check
%           negative error bars; it does check negative variances of course)
%
%   mask    [Optional] array of ones and zeros, with the same number of elements as the data
%           array, that indicates which of the data points are to be retained for
%           fitting (true to retain, false to ignore)
%
% Output:
% -------
%   sel     Mask array of same shape as data. true for bins to keep, false to discard.
%
% 
%  Advanced use: in addition the following two arguments, if present, suppress failure or the
%  display of informational messges. Instead, the messages are returned to be used as desired.
%
%   ok      =true if worked, =false if error
%
%   mess    messages: if ok=true then informational or warning, if ok=false then the error message

if nargout>1
    return_with_errors=true;
    sel=[];
    ok=false;
    mess='';
    imess=0;
    mess_cell={};
else
    return_with_errors=false;
end

% Check mask array
if exist('mask','var') && ~isempty(mask)
    if ~(isnumeric(mask)||islogical(mask)) || numel(mask)~=numel(y)
        mess='Mask array must be numeric or logical array with same number of elements as data array';
        if return_with_errors, return, else error(mess), end
    end
    if ~any(mask)
        mess='The input mask array masks all data points';
        sel = false(size(y));
        ok = true;
        if ~return_with_errors, disp(mess), end
        return
    end
    mask = reshape(mask,size(y));
else
    mask = true(size(y));
end

% Get points whose x values that are finite
ok_xvals = true(size(y));
if ~isempty(x)
    for i = 1:numel(x)
        ok_xvals = isfinite(x{i}) & ok_xvals;
    end
    if ~any(ok_xvals(mask))
        mess='All points have at least one undefined (infinite or NaN) coordinate value';
        sel = false(size(y));
        ok = true;
        if ~return_with_errors, disp(mess), end
        return
    elseif ~all(ok_xvals(mask))
        npts=numel(ok_xvals(mask)) - nnz(ok_xvals(mask));
        fracpts=npts./numel(x{i});
        mess=[num2str(npts),' points with at least one undefined (infinite or NaN) coordinate ',...
            'value have been removed from fit, which is ',num2str(100*fracpts),' % of the number of ',...
            'points in this dataset'];
        if ~return_with_errors, disp(mess), else imess=imess+1; mess_cell{imess}=mess; end
    end
end
        
% Remove data points with non-finite y values
ok_yvals = isfinite(y);
if ~any(ok_yvals(mask))
    mess='All points have undefined (infinite or NaN) data values';
    sel = false(size(y));
    ok = true;
    if ~return_with_errors, disp(mess), end
    return
elseif ~all(ok_yvals(mask))
    npts=numel(ok_yvals(mask)) - nnz(ok_yvals(mask));
    fracpts=npts./numel(y);
    mess=[num2str(npts),' points with undefined (infinite or NaN) data values ',...
            'have been removed from fit, which is ',num2str(100*fracpts),' % of the number of ',...
            'points in this dataset'];
    if ~return_with_errors, disp(mess), else imess=imess+1; mess_cell{imess}=mess; end
end

% Remove data points with zero or negative error bars
ok_ebars = isfinite(e) & e>0;
if ~any(ok_ebars(mask))
    mess='All points have zero, negative or undefined (infinite or NaN) error bars';
    sel = false(size(y));
    ok = true;
    if ~return_with_errors, disp(mess), end
    return
elseif ~all(ok_ebars(mask))
    npts=numel(ok_ebars(mask)) - nnz(ok_ebars(mask));
    fracpts=npts./numel(y);
    mess=[num2str(npts),' with zero, negative or undefined (infinite or NaN) error bars ',...
            'have been removed from fit, which is ',num2str(100*fracpts),' % of the number of points',...
            ' in this dataset'];
    if ~return_with_errors, disp(mess), else imess=imess+1; mess_cell{imess}=mess; end
end

% Combine all the masking criteria
ok_data = ok_xvals & ok_yvals & ok_ebars;
if ~any(ok_data(mask))
    mess='All points have either non-finite coordinate or data values, or non-finite, zero or negative error bars';
    sel = false(size(y));
    ok = true;
    if ~return_with_errors, disp(mess), end
    return
end

% Get final list of points to fit
sel = ok_data & mask;
ok=true;
if return_with_errors && ~isempty(mess_cell)
    mess=mess_cell;
else
    mess='';
end
