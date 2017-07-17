function [ok,message] = check_common_fields_(w)
% Check validity of connected fields for the object
%
%   >> [ok, message,wout] = check_common_fields_(w)
%
%   w       the object of the class
%
%   ok      ok=true if valid, =false if not
%   message Message if not a valid object, empty string if is valid.
%
%
%   >> [ok, message,wout,...] = check_common_fields_(w,...)
%
ok=true;
message = [];

if numel(w.signal_)~=numel(w.error_)
    ok = false;
    message='Length of signal and error arrays must be the same';
    return
end
if ~(numel(w.x_)==numel(w.signal_)||numel(w.x_)==numel(w.signal_)+1)
    ok=false;
    message='The lengths of x-axis must be equal to length of signal or be length+1';
    return
end

