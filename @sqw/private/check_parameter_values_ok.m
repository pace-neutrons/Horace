function [val_out,mess]=check_parameter_values_ok(val,nfiles,nel,val_name,row_name,range,boundary_ok)
% Check value is an array size [nfiles,nel], or a vector with nel elements
% when it will be turned into an array size [nfiles,nel]
% Also check that the elements are within the required range (given as 2 x nel matrix)
% Values on the boundaries are acceptable by default; indicate otherwise with a 2 x nel logical array
%
% Example:
%


mess='';
if nel==1
    if isscalar(val) && nfiles>1 && isnumeric(val)
        val_out=repmat(val,[nfiles,1]);
    elseif isvector(val) && length(val)==nfiles && isnumeric(val)
        if size(val,2)==1
            val_out=val;
        else
            val_out=val';
        end
    else
        val_out=[];
        if nfiles>1
            mess=['''',val_name,''' must be a single number, or vector with length equal to ',row_name'];
        else
            mess=['''',val_name,''' must be a single number'];
        end
        return
    end
elseif nel>1
    if isvector(val) && length(val)==nel && isnumeric(val)
        val_out=repmat(val(:)',[nfiles,1]);
    elseif numel(size(val))==2 && all(size(val)==[nfiles,nel]) && isnumeric(val)
        val_out=val;
    else
        val_out=[];
        if nfiles>1
            mess=['''',val_name,''' must be a vector length ',num2str(nel),' or array with ',...
                num2str(nel),' columns and the number of rows equal to ',row_name];
        else
            mess=['''',val_name,''' must be a vector length ',num2str(nel)];
        end
        return
    end
else
    error('Incorrect use of this function')
end

% Check range, if necessary
if exist('range','var')
    % Check range input OK
    if ~(isequal(size(range),[2,nel]) || (nel==1 && isequal(size(range),[1,2])))
        error('Check size of ''range'' array')
    end
    if nel==1 && size(range,2)==2
        range=range(:);     % guarantee a column if nel==1
    end
    % Check boundary_ok
    if exist('boundary_ok','var')
        boundary_ok=logical(boundary_ok);
        if ~(isequal(size(boundary_ok),[2,nel]) || (nel==1 && isequal(size(boundary_ok),[1,2])))
            error('Check size of ''boundary_ok'' array')
        end
        if nel==1 && size(boundary_ok,2)==2
            boundary_ok=boundary_ok(:);     % guarantee a column if nel==1
        end
    else
        boundary_ok=true(2,nel);
    end
    % Now check ranges
    v_lo=repmat(range(1,:),[nfiles,1]);
    v_hi=repmat(range(2,:),[nfiles,1]);
    ok_lo=repmat(boundary_ok(1,:),[nfiles,1]);
    ok_hi=repmat(boundary_ok(2,:),[nfiles,1]);
    ok=true(nfiles,nel);
    ok(ok_lo)  = ok(ok_lo)  & (val_out(ok_lo)>=v_lo(ok_lo));
    ok(~ok_lo) = ok(~ok_lo) & (val_out(~ok_lo)>v_lo(~ok_lo));
    ok(ok_hi)  = ok(ok_hi)  & (val_out(ok_hi)<=v_hi(ok_hi));
    ok(~ok_hi) = ok(~ok_hi) & (val_out(~ok_hi)<v_hi(~ok_hi));
    if ~all(ok(:))
        mess=['Check value(s) of ''',val_name,''' is(are) valid'];
    end
end
