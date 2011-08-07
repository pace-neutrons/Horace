function [x_out, ok, mess]=rebin_1d_hist_get_xarr (x_in, xbounds)
% Deprecated function, replaced by bin_boundaries_from_descriptor

[x_out, ok, mess]=bin_boundaries_from_descriptor (x_in, xbounds);
if nargout==1 && ~ok
    error(mess)
end
