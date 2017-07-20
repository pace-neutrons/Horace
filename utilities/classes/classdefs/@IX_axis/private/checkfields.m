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


fields = {'caption';'units';'code';'ticks'};  % column

ok=false;
message='';
wout=w;

if isequal(fieldnames(w),fields)
    % Check caption
    
    
     
    % Check ticks
    if isstruct(w.ticks)
 
    else
        message='ticks information must be a structure with fields ''positions'' and ''labels'''; return
    end
    
else
    message='Fields inconsistent with class type'; return
end

% OK if got to here
ok=true;
