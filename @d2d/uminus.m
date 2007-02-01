function wout = uminus(w1)
% Implement -w1

% Original author: T.G.Perring
%
% $Revision: 35 $ ($Date: 2005-07-12 14:01:06 +0100 (Tue, 12 Jul 2005) $)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

wout=w1;
for i=1:length(w1);
    wout.s=-w1.s;
end
