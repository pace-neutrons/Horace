function display_single (w)
% Display useful information from cut object
%
%   >> display_single(w)

% Original author: T.G.Perring

npnt=numel(w.npixels);
npix=size(w.pixels,1);

if ~isempty(w.appendix)
    disp(['   ',num2str(npnt),' point(s) and ',num2str(npix),' pixel(s) in Mfit .cut format'])
else
    disp(['   ',num2str(npnt),' point(s) and ',num2str(npix),' pixel(s) in .cut format'])
end
disp(' ')
