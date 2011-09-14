function display_single (w)
% Display useful information from spe object
%
%   >> display_single(w)

% Original author: T.G.Perring

ne=size(w.S,1);
nd=size(w.S,2);
disp(['   ',num2str(ne),' energy bin(s) and ',num2str(nd),' workspaces in spe object'])
disp(' ')
