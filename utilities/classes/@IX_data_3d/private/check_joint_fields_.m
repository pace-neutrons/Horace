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


[sz_sig,ok,message] = get_size(w.signal_,'signal');
if ~ok
    return
end

[sz_err,ok,message] = get_size(w.error_,'error');
if ~ok
    return
end


if numel(sz_sig) ~=numel(sz_err)
    ok = false;
    message=sprintf('numel(size(signal))=%d, numel(size(error))=%d; shape of signal ~= shape of error',...
        numel(sz_sig),numel(sz_err));
    return
end

if ~all(sz_sig ==sz_err)
    ok = false;
    message=sprintf('size(signal)=[%d,%d,%d], size(error)=[%d,%d,%d]; size(signal)~=size(error)',...
        sz_sig,sz_err);
    return
end
%
sz = sz_sig;

if ~(numel(w.x_)==sz(1)||numel(w.x_)==sz(1)+1)
    ok=false;
    message=sprintf('size(signal,1)=%d, numel(x)=%d; size(signal,1) must be equal to numel(x) or numel(x)+1',...
        sz(1),numel(w.x_));
    return
end

if ~(numel(w.y_)==sz(2)||numel(w.y_)==sz(2)+1)
    ok=false;
    message=sprintf('size(signal,2)=%d, numel(y)=%d; size(signal,2) must be equal to numel(y) or numel(y)+1',...
        sz(2),numel(w.y_));
    return
end

if ~(numel(w.z_)==sz(3)||numel(w.z_)==sz(3)+1)
    ok=false;
    message=sprintf('size(signal,3)=%d, numel(z)=%d; size(signal,3) must be equal to numel(z) or numel(z)+1',...
        sz(3),numel(w.z_));
    return
end
%
function [sz,ok,message] = get_size(signal,name)

sz=size(signal);
ok = true;
message  = [];

if numel(sz)>3
    ok=false;
    message = sprintf('Dimensionality of %s array=%d. This exceeds max allowed value == 3',numel(sz),name);
elseif numel(sz)<3
    sz=[sz,ones(1,3-numel(sz))];
end
