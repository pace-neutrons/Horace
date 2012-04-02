function [ok,mess]=equal_to_tol(a,b,tol)
% Check that all elements of a pair objects are equal, with numeric arrays within a specified tolerance
%
%   >> ok=equal_to_tol(a,b)
%   >> ok=equal_to_tol(a,b,tol)
%   >> [ok,mess]=equal_to_tol(a,b,tol)
%
%
% Input:
% ------
%   a,b     test objects with same sizes
%   tol     tolerance (default: equality required)
%               +ve number: absolute tolerance  abserr = abs(a-b)
%               -ve number: relative tolerance  relerr = abs(a-b)/max(abs(a),abs(b))
%
%           The relative error is defined this way to ensure that 
%           
% Output:
% -------
%   ok      true if every element satisfies tolerance criterion
%   mess    error message if ~ok ('' if ok)

if nargin==2
    opt.tol=0;    % default is to force equality of numeric elements
else
    opt.tol=tol;
end
opt.nan_equal=true;

[ok,mess]=equal_to_tol_internal(a,b,opt);

%--------------------------------------------------------------------------------------------------
function [ok,mess]=equal_to_tol_internal(a,b,opt)

if ~isequal(size(a),size(b))
    ok=false; mess='Sizes of objects or matching fields of objects or structure are not equal'; return
else
    if (isobject(a) && isobject(b)) || (isstruct(a) && isstruct(b))
        name=fieldnames(a);
        if ~isequal(name,fieldnames(b))
            ok=false; mess='Field names of objects or structures beinbg compared do not match'; return
        end
        for i=1:numel(a)
            for j=1:numel(name)
                if isobject(a)
                    [ok,mess]=equal_to_tol_internal(struct(a(i)).(name{j}),struct(b(i)).(name{j}),opt);
                else
                    [ok,mess]=equal_to_tol_internal(a(i).(name{j}),b(i).(name{j}),opt);
                end
                if ~ok, return, end
            end
        end
    elseif iscell(a) && iscell(b)
        for i=1:numel(a)
            [ok,mess]=equal_to_tol_internal(a{i},b{i},opt);
            if ~ok, return, end
        end
    elseif isnumeric(a) && isnumeric(b)
        [ok,mess]=equal_to_tol_numeric(a,b,opt.tol,opt.nan_equal);
        if ~ok, return, end
    else
        if ~isequal(a,b)
            ok=false;
            mess='Non-numeric fields not equal';
            return
        end
    end
    ok=true; mess='';
end

%--------------------------------------------------------------------------------------------------
function [ok,mess]=equal_to_tol_numeric(a,b,tol,nan_equal)
if isequal(size(a),size(b))
    % If NaNs are to be ignored, remove them from consideration
    if nan_equal
        keep=~isnan(a);
        if ~all(keep==~isnan(b))    % check NaNs have the same locations in both arrays
            ok=false;
            mess='NaN elements not in same locations in numeric arrays being compared';
            return
        elseif ~any(keep)   % if all elements are Nans, can simply return
            ok=true;
            mess='';
            return
        elseif ~all(keep)   % filter out elements if some to be ignored
            a=a(keep);
            b=b(keep);
        end
    end
    % Compare elements
    if tol==0
        ok=all(a==b);
    elseif tol>0
        ok=all(abs(a-b)<=tol);
    else
        den=max(abs(a),abs(b));
        ok=all((abs(a-b)./den<=abs(tol))|den==0);   % if both are zero, then accept
    end
    if ok
        mess='';
    else
        mess='Numeric arrays not equal within requested tolerance';
    end
else
    ok=false;
    mess='Numeric arrays have different sizes';
end
