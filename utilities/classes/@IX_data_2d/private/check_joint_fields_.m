function [ok,message] = check_joint_fields_(w)
% Check validity of interconnected fields of the object
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


if ~all(size(w.signal_)==size(w.error_))
    ok = false;
    message=sprintf('size(signal)=[%d,%d], size(error)=[%d,%d]; size(signal)~=size(error)',...
        size(w.signal_),size(w.error_));
    return
end
%
if ~(numel(w.xyz_{1})==size(w.signal_,1)||numel(w.xyz_{1})==size(w.signal_,1)+1)
    ok=false;
    message=sprintf('size(signal,1)=%d, numel(x)=%d; size(signal,1) must be equal to numel(x) or numel(x)+1',...
        size(w.signal_,1),numel(w.xyz_{1}));
    return
end
if ~(numel(w.xyz_{2})==size(w.signal_,2)||numel(w.xyz_{2})==size(w.signal_,2)+1)
    ok=false;
    message=sprintf('size(signal,2)=%d, numel(y)=%d; size(signal,2)  must be equal to numel(y) or numel(y)+1',...
        size(w.signal_,2),numel(w.xyz_{2}));
    return
end


