function [s,e]=convert_signal_error_(s,e,npix)
% Convert prototype (July 2007) format into standard format signal and error arrays
% Prototype format files have zeros for signal and variance arrays with no pixels
pixels = npix~=0;
s(pixels) = s(pixels)./npix(pixels);
e(pixels) = e(pixels)./(npix(pixels).^2);


