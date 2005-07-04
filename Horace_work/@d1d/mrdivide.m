function wout = mrdivide(w1,w2)
% MRDIVIDE  Implement w1 / w2 for a 1D dataset.
%        Handles the case where one or both objects are a D1D
%
%   >> w = w1 / w2

if (isa(w1,'d1d') & isa(w2,'d1d'))
    w = d1d_to_spectrum(w1) / d1d_to_spectrum(w2);
    wout = combine_d1d_spectrum (w1, w);
    
elseif (isa(w1,'d1d') & (isa(w2,'spectrum')|isa(w2,'double')))
    w = d1d_to_spectrum(w1) / w2;
    wout = combine_d1d_spectrum (w1, w);
    
elseif ((isa(w1,'spectrum')|isa(w1,'double')) & isa(w2,'d1d'))
    w = w1 / d1d_to_spectrum(w2);
    wout = combine_d1d_spectrum (w2, w);
    
else
    error ('only division of D1D and spectra or reals defined')
end
