function [ok, message, wout] = checkfields (w)
% Check validity of all fields for an object
%
%   >> [ok, message,wout] = checkfields (w)
%
%   w       structure or object of the class
%
%   ok      ok=true if valid, =false if not
%   message Message if not a valid object, empty string if is valid.
%   wout    Output structure or object of the class 
%           wout can be an altered version of the input structure or object that must
%           have the same fields. For example, if a column array is provided for a field
%           value, but one wants the array to be a row, then checkfields could take the
%           transpose. If the facility is not wanted, simply include the line wout=win.
%
%     Because checkfields must be in the folder defining the class, it
%     can change fields of an object without calling set.m, which means
%     that we do not get recursion from the call that set.m makes to 
%     isvalid.m and the consequent call to checkfields.m ...
%       
%     Can have further arguments as desired for a particular class
%
%   >> [ok, message,wout,...] = checkfields (w,...)
    
% Original author: T.G.Perring


fields = {'s';'e';'title'};  % column vector of expected fields in class structure

ok=false;
message='';
wout=w;

if isequal(fieldnames(w),fields)
    if ~(isnumeric(w.s) && isnumeric(w.e) && (isequal(size(w.s),size(w.e))||isequal(size(w.e),[0,0])))
        % Note: variance array can be empty, in which case it will be ignored
        message='Numeric array sizes for fields ''s'' and ''e'' incompatible';
        return
    end
    if any(w.e<0)
        message='One or more elements of field ''e'' <0';
        return
    end
    if ~(ischar(w.title)||iscellstr(w.title))
        message='Title field must be character or cellstr of characters';
    end
else
    message='fields inconsistent with class type';
    return
end

% OK if got to here
ok=true;
