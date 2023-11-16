function [s, e] = normalize_signal(s, e, npix)
% Convert accumulated signal and error into the
% bin-average signal and error

s = s./npix;
no_pix = (npix == 0);  % true where no pixels contribute to given bin

% By convention, signal and error are zero if no pixels contribute to bin
s(no_pix) = 0;
if ~isempty(e)
    e = e./(npix.^2);
    e(no_pix) = 0;
end

