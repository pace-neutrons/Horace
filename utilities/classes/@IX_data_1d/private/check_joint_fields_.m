function [ok,message] = check_joint_fields_(w)
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
    message=sprintf('numel(signal)=%d, numel(error)=%d; numel(signal)~=numel(error)',...
        numel(w.signal_),numel(w.error_));
    return
end
if ~(numel(w.x_)==numel(w.signal_)||numel(w.x_)==numel(w.signal_)+1)
    ok=false;
    message=sprintf('numel(signal)=%d, numel(x)=%d; numel(signal)  must be equal to numel(x) or numel(x)+1',...
        numel(w.signal_),numel(w.x_));
    return
end

