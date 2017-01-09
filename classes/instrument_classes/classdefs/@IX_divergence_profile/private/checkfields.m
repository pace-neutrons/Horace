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

fields = {'name';'angle';'profile'};  % column vector of expected fields in class structure

ok=false;
message='';
wout=w;

if isequal(fieldnames(w),fields)
    if ~is_string(w.name)
        message='Fermi chopper name must be a character string';
        return
    end
    npnt=numel(w.angle);
    if ~isnumeric(w.angle) || npnt<3 || ~all(diff(w.angle(:))>0)
        message=['Angles must be a strictly monotonic array of at least three elements'];
        return
    else
        wout.angle=wout.angle(:);   % ensure column vector
    end
    if ~isnumeric(w.profile) || numel(w.profile)~=npnt || any(w.profile(:)<0) ||...
            w.profile(1)~=0 || w.profile(end)~=0
        message='profile must have the same number of elements as angle, be all positive, first and last elements = 0';
        return
    else
        wout.profile=wout.profile(:); % ensure column vector
        if sum(wout.profile)<0
            message='At least one point in the profile must be greater than zero';
            return
        end
    end
else
    message='fields inconsistent with class type';
    return
end

% OK if got to here
ok=true;
