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
    
fields = {'name';'distance';'angle';'pulse_model';'pp';'flux_model';'pf';...
          'width';'height';'thickness';'temperature'};  % column vector of expected fields in class structure

ok=false;
message='';
wout=w;

if isequal(fieldnames(w),fields)
    if ~is_string(w.name)
        message='Moderator name must be a character string';
        return
    end
    for i=[2,8,9,10,11]
        if ~isnumeric(w.(fields{i})) || ~isscalar(w.(fields{i})) || w.(fields{i})<0
            message=['Parameter ''',fields{i},''' must be greater or equal to zero'];
            return
        end
    end
    for i=3
        if ~isnumeric(w.angle) || ~isscalar(w.angle)
            message='Parameter ''angle'' must be a numeric scalar';
            return
        end
    end
    if ~is_string(w.pulse_model)
        message='Moderator pulse model must be a character string';
        return
    end
    if ~is_string(w.flux_model)
        message='Moderator pulse model must be a character string';
        return
    end
else
    message='fields inconsistent with class type';
    return
end

% OK if got to here
ok=true;
