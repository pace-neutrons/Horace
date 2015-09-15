function [ok, message, wout] = checkfields (w)
% Check fields for Horace/Tobyfit phxObject objects
%
%   >> [ok, message, wout] = checkfields (w)
%
%   w       structure or object of the class
%
%   ok      ok=true if valid, =false if not
%   message Message if not a valid object, empty string if is valiw.
%   wout    Output structure or object of the class
%           wout can be an altered version of the input structure or object that must
%           have the same fields. For example, if a column array is provided for a field
%           value, but one wants the array to be a row, then checkfields could take the
%           transpose. If the facility is not wanted, simply include the line wout=win.
%
%     Because checkfields must be in the folder defining the class, it
%     can change fields of an object without calling set.m, which means
%     that we do not get recursion from the call that set.m makes to
%     isvaliw.m and the consequent call to checkfields.m ...
%
%     Can have further arguments as desired for a particular class
%
%   >> [ok, message,wout,...] = checkfields (w,...)

% Original author: T.G.Perring


fields = {'filename';'filepath';'group';'phi';'azim';'dphi';'danght'};  % column

ok=false;
message='';
wout=w;

if isequal(fieldnames(wout),fields)
    if ~is_string(wout.filename)||~is_string(wout.filepath)   % allows empty strings
        message='File name and path must both be character strings'; return
    end
    ndet=numel(wout.group);
    % Make fields row vectors
    if ~size(wout.group,1)==1, wout.group=wout.group(:)'; end
    if ~size(wout.phi,1)==1, wout.phi=wout.phi(:)'; end
    if ~size(wout.azim,1)==1, wout.azim=wout.azim(:)'; end
    if ~size(wout.dphi,1)==1, wout.dphi=wout.dphi(:)'; end
    if ~size(wout.danght,1)==1, wout.danght=wout.danght(:)'; end
    
    % Check numeric, length and any conditions on magnitude
    message_arg_types='Detector group numbers, angles and sizes must all be numeric arrays with equal length';

    [ok,numeric_and_nvals_ok]=check_numeric(wout.group,ndet,true,true,false);
    if ~ok
        if numeric_and_nvals_ok
            message='Detector group numbers must be unique integers greater than zero'; return
        else
            message=message_arg_types; return
        end
    elseif numel(unique(wout.group))~=ndet
        ok=false;
        message='Detector group numbers must be unique'; return
    end
    
    ok=check_numeric(wout.phi,ndet,false,false,true);
    if ~ok
        message=message_arg_types; return
    end
    
    ok=check_numeric(wout.phi,ndet,false,false,true);
    if ~ok
        message=message_arg_types; return
    end
    
    [ok,numeric_and_nvals_ok]=check_numeric(wout.dphi,ndet,false,true,true);
    if ~ok
        if numeric_and_nvals_ok
            message='Detector widths must all be greater than or equal to zero'; return
        else
            message=message_arg_types; return
        end
    end
    
    [ok,numeric_and_nvals_ok]=check_numeric(wout.danght,ndet,false,true,true);
    if ~ok
        if numeric_and_nvals_ok
            message='Detector heights must all be greater than or equal to zero'; return
        else
            message=message_arg_types; return
        end
    end
    
else
    message='Fields inconsistent with phxObject object';
    return
end

% OK if got to here
ok=true;

%------------------------------------------------------------------------------
function [ok,numeric_and_nvals_ok]=check_numeric(arr,nvals,is_integer,is_positive,zero_ok)
% Check a vector is numeric with length nvals, with options about
% having to be integer, positive only, and, if positive, if zero is ok.
% If the array is (correctly) empty, then these checks do not need to be done
% as the array is deemed valid.
ok=false;
numeric_and_nvals_ok=false;
if isnumeric(arr) && numel(arr)==nvals
    numeric_and_nvals_ok=true;
    if nvals>0
        if is_integer
            if ~all(rem(arr,1)==0), return, end
        end
        if is_positive
            if zero_ok
                if any(arr<0), return, end
            else
                if any(arr<=0), return, end
            end
        end
    end
    % All fine if got to here
    ok=true;
end
