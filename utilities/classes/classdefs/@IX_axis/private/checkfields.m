function [ok, message, wout] = checkfields (w)
% Check validity of all fields for an object
%
%   >> [ok, message,wout] = checkfields (w)
%
%   w       structure or object of the class
%
%   ok      ok=true if valid, =false if not
%   message Message if not a valid sqw object, empty string if is valid.
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


fields = {'caption';'units';'code'};  % column

ok=false;
message='';
wout=w;

if isequal(fieldnames(w),fields)
    if ~(ischar(w.caption)||iscellstr(w.caption))
        message='Caption must be character or cell array of strings';
    end
    if ~ischar(w.units) && size(w.units,1)==1
        message='Axis units must be character string';
    end
    if ~ischar(w.code) && size(w.units,1)==1
        message='Axis code must be character string';
    end
    if ischar(w.caption)
        wout.caption=cellstr(w.caption);
    end
else
    message='Fields inconsistent with class type';
    return
end

% OK if got to here
ok=true;
