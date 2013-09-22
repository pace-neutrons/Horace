function display_single (w)
% Display useful information from a single instance of an object i.e. a scalar instance
%
%   >> display_single(w)
%
% *** REQUIRED PRIVATE METHOD ***

nw=numel(w.ns);
ns=numel(w.s);

disp(' ')
disp(['   Map with ',num2str(nw),' workspace(s) containing ',num2str(ns),' spectra'])
disp(' ')
