function [val_out,mess]=check_parameter_values_ok(val,nfiles,nel,val_name,row_name,range,boundary_ok)
% Check value is an array size [nfiles,nel], or a vector with nel elements
%
%   >> [val_out,mess]=check_parameter_values_ok(val,nfiles,nel,val_name,row_name,range,boundary_ok)
%
% Input:
% ------
%   val         Numerical array to be checked
%   nfiles      Expected number of entries
%   nel         Expected number of elements per entry
%   val_name    Name of array for error messages
%   row_name    Entry description for error messages
%
% Optionally:
%   range       Range in which val must be confined
%                 - vector length=2    (if expect scalar value i.e. nel=1)
%                 - array size [2,nel] (if expect vector value i.e. nel>1)
%   boundary_ok Logical array with same size as argument range, where elements
%               indicate if the value can lie on the boundary (true) or not (false)
%
% Output:
% -------
%   val_out     Array with input array val reshaped and (if necessary) replicated 
%               so that it has size [nfiles,nel]
%   mess        Error message. Empty if all is OK.
%
%
% EXAMPLES
%   >> [gl_out,mess]=check_parameter_values_ok(gl,nfile,1,'gl','the number of spe files');
%
%   >> [angdeg_out,mess]=check_parameter_values_ok(angdeg,nfile,3,'angdeg',...
%                               'the number of spe files',[0,0,0;180,180,180],false(2,3));
%
%   >> [efix_out,mess]=check_parameter_values_ok(efix,nfile,1,'efix',...
%                               'the number of spe files',[0,Inf],[false,true]);

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
            mess=['''',val_name,''' must be a single number, or vector with length equal to ',row_name];
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
