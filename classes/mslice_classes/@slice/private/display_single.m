function display_single (w)
% Display useful information from slice object
%
%   >> display_single(w)

% Original author: T.G.Perring

npnt=numel(w.npixels);
npix=size(w.pixels,1);
disp(['   ',num2str(npnt),' point(s) and ',num2str(npix),' pixel(s) in mslice/Tobyfit slice object'])
disp(' ')
