function wout = mpower(w1,w2)
% MPOWER  Implement w1 ^ w2 for a 1D dataset.
%
%   >> w = w1 ^ w2
%
%   If w1, w2 are both 1D datasets, or one is an mgenie spectrum:
%       the operation is performed element-by-element
%   if one of w1 or w2 is a double:
%       the operation is applied to each element of the spectrum

if (isa(w1,'d1d') & isa(w2,'d1d'))
    w = d1d_to_spectrum(w1) ^ d1d_to_spectrum(w2);
    wout = combine_d1d_spectrum (w1, w);
    
elseif (isa(w1,'d1d') & (isa(w2,'spectrum')|isa(w2,'double')))
    w = d1d_to_spectrum(w1) ^ w2;
    wout = combine_d1d_spectrum (w1, w);
    
elseif ((isa(w1,'spectrum')|isa(w1,'double')) & isa(w2,'d1d'))
    w = w1 ^ d1d_to_spectrum(w2);
    wout = combine_d1d_spectrum (w2, w);
    
else
    error ('only power-raising of D1D and spectra or reals defined')
end
