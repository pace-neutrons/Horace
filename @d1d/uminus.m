function wout = uminus(w1)
% Implement -w1

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

wout=w1;
for i=1:length(w1);
    wout.s=-w1.s;
end
