function wout = sigvar (w)
% Create sigvar object
% 
%   >> wout = sigvar (w)

% Original author: T.G.Perring

wout = sigvar(w.signal, (w.error).^2);
