function wout = single_mrdivide(w1,w2)
% Implement w1 / w2 for 2D datasets
%
%   >> w = w1 / w2
%
%   If w1, w2 are datasets of the same size:
%       the operation is performed element-by-element
%   if one of w1 or w2 is a double:
%        - if a scalar, apply to each element of the dataset
%        - if an array of the same size as the signal array, apply element by element

class_type = 'd2d';

if isa(w1,class_type) & isa(w2,class_type)
    if size(w1.s)==size(w2.s)
        wout = w1;
        [s1,e1]=dnd_normalise_sigerr(w1.s,w1.e,w1.n);
        [s2,e2]=dnd_normalise_sigerr(w2.s,w2.e,w2.n);
        wout.s = s1 ./ s2;
        wout.e = e1./(s2.^2) + e2.*((wout.s./s2).^2);
        wout.n = double(~isnan(wout.s));
    else
        error ('Sizes of signal arrays in the datasets are different')
    end
    
elseif isa(w1,class_type) && isa(w2,'double')
    if isscalar(w2) || (all(ndims(w1.s)==ndims(w2)) && all(size(w1.s)==size(w2)))
        wout = w1;
        [s1,e1]=dnd_normalise_sigerr(w1.s,w1.e,w1.n);
        wout.s = s1 ./ w2;
        wout.e = e1./(w2.^2);
        wout.n = double(~isnan(wout.s));
    else
        error ('Check that the numeric variable is scalar or array with same size as dataset signal')
    end
    
elseif (isa(w2,class_type) & isa(w1,'double'))
    if isscalar(w1) || (all(ndims(w2.s)==ndims(w1)) && all(size(w2.s)==size(w1)))
        wout = w2;
        [s2,e2]=dnd_normalise_sigerr(w2.s,w2.e,w2.n);
        wout.s = w1 ./ s2;
        wout.e = e2.*((wout.s./s2).^2);
        wout.n = double(~isnan(wout.s));
    else
        error ('Check that the numeric variable is scalar or array with same size as dataset signal')
    end
    
else
    error ('addition of datasets and reals only defined')
end
     