function x = sigvar_getx (w)
% Get x values from object. Size must match output of sigvar_get
% 
%   >> x = sigvar_getx (w)

% Original author: T.G.Perring

if numel(w.signal)~=numel(w.x)
    x = 0.5*(w.x(2:end)+w.x(1:end-1))';
else
    x = w.x';
end
