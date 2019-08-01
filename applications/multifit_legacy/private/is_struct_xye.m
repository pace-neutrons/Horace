function [ok,mess,ndim] = is_struct_xye (w)
% Determine if an argument is structure array with valid fields x,y,e
%
%   >> [ok,mess,ndim] = is_struct_xye (w)
%
% Input:
% ------
%   w       Structure array with fields x,y and e, where:
%
%   w(i).x  Coordinates of the data points:
%               - An array of any size whose outer dimension gives the
%                coordinate dimension i.e. x(:,:,...:,1) is the array of
%                x values along axis 1, x(:,:,...:,2 along axis 2) ...
%                to x(:,:,...:,n) along the nth axis.
%                 If size(x) matches size(y), then the outer dimension is taken
%                as unity and the data is considered to be one dimensional
%                   e.g. x=[1.1, 2.3, 4.3    &  y=[110, 121, 131
%                           1.7, 5.4, 7.0]         141, 343,  89]
%
%      OR       - A cell array of length n, where x{i} gives the coordinates in the
%                ith dimension for all the data points. The arrays can have any
%                size, but they must all have the same size.
%
%   w(i).y  Array of the of data values at the points defined by x. Must
%           have the same same size as x(:,:,...:,i) if x is an array, or
%           of x{i} if x is a cell array.
%
%   w(i).e  Array of the corresponding error bars. Must have same size as y.
%
%
% Output:
% -------
%   ok      Status flag: =true if each element of argument w satisfies one of
%          the above formats; =false otherwise (the elements of w do not need
%          to all have the same format)
%
%   mess    Error message: ='' if OK, contains error message if not OK.
%
%   ndim    Array with size equal to that of w with the dimensionality of
%          each of the data sets.

ok=false;
ndim=NaN(size(w));

for i=1:numel(w)
    if numel(w)>1
        message_opening=['Data structure array element ',arraystr(size(w),i)];
    else
        message_opening='Data';
    end
    if ~all(isfield(w(i),{'x','y','e'}))
        ndim=[];
        mess=[message_opening,' does not have fields ''x'',''y'' and ''e'''];
        return
    end
    if ~(isnumeric(w(i).y) && isnumeric(w(i).e))
        ndim=[];
        mess=[message_opening,' signal and error arrays are not numeric'];
        return
    elseif isempty(w(i).y) || isempty(w(i).e)
        ndim=[];
        mess=[message_opening,' signal and/or error array is empty'];
        return
    else
        szy=size(w(i).y);
        if ~isequal(szy,size(w(i).e))
            ndim=[];
            mess=[message_opening,' signal and error arrays are not same size'];
            return
        end
    end
    if isnumeric(w(i).x) && isnumeric(w(i).y) && isnumeric(w(i).e)
        if isempty(w(i).x)
            ndim=[];
            mess=[message_opening,' x-coordinate array is empty'];
            return
        end
        sz=size(w(i).x);
        if ~isequal(sz,szy)
            if numel(szy)==2 && szy(2)==1, szy=szy(1); end   % y array is a column vector, so strip the redundant outer dimension
            if ~isequal(sz(1:end-1),szy)
                ndim=[];
                mess=[message_opening,' signal and error array sizes do not match coordinate array size'];
                return
            end
            ndim(i)=sz(end);
        else
            ndim(i)=1;
        end
    elseif iscell(w(i).x)
        if isempty(w(i).x)
            ndim=[];
            mess=[message_opening,' cell array of x-coordinates is empty'];
            return
        end
        sz=size(w(i).x{1});
        for j=1:length(w(i).x)
            if ~isnumeric(w(i).x{j})
                ndim=[];
                mess=[message_opening,' cell array of x-coordinate array(s) not all numeric'];
                return
            elseif ~isequal(sz,size(w(i).x{j}))
                ndim=[];
                mess=[message_opening,' cell array of x-coordinates array(s) not all same size'];
                return
            elseif isempty(w(i).x{j})
                ndim=[];
                mess=[message_opening,' cell array of x-coordinates array(s) has at least one empty array'];
                return
            end
        end
        if ~isequal(sz,szy)
            ndim=[];
            mess=[message_opening,' signal and error array sizes do not match coordinate array(s) size'];
            return
        end
        ndim(i)=numel(w(i).x);
    else
        ndim=[];
        mess=[message_opening,' x-coordinate must be a numeric array or cell array of numeric arrays'];
        return
    end
end
ok=true;
mess='';
