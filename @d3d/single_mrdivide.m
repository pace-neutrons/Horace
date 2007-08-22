function wout = single_mrdivide(w1,w2,class_type)
% Implement w1 / w2
%
%   >> w = w1 / w2
%
%   If w1, w2 are datasets of the same size:
%       the operation is performed element-by-element
%   if one of w1 or w2 is a double:
%        - if a scalar, apply to each element of the dataset
%        - if an array of the same size as the signal array, apply element by element

if isa(w1,class_type) && isa(w2,class_type)
    if size(w1.s)==size(w2.s)
        wout = w1;
        
        % set nans to 0 so that operation does not yeild nan
%         w1nan = isnan(w1.s);        w2nan = isnan(w2.s);
%         nanindex = w1nan & w2nan;
% 
%         w1.s(w1nan) = 0;            w1.e(w1nan) = 0;
%         w2.s(w2nan) = 0;            w2.e(w2nan) = 0;
%         
        wout.s = w1.s ./ w2.s;
        wout.e = w1.e./(w2.s.^2) + w2.e.*((wout.s./w2.s).^2);
        
        % if both datasets were nan, put nan back in
%         wout.s(nanindex) = nan;     wout.e(nanindex) = nan;
        
    else
        error ('Sizes of signal arrays in the datasets are different')
    end
    
elseif isa(w1,class_type) && isa(w2,'double')
    if isscalar(w2) || (all(ndims(w1.s)==ndims(w2)) && all(size(w1.s)==size(w2)))
        
        wout = w1;
        wout.s = w1.s ./ w2;
        wout.e = w1.e./(w2.^2);


    else
        error ('Check that the numeric variable is scalar or array with same size as dataset signal')
    end
    
elseif (isa(w2,class_type) && isa(w1,'double'))
    if isscalar(w1) || (all(ndims(w2.s)==ndims(w1)) && all(size(w2.s)==size(w1)))

        wout = w2;
        wout.s = w1 ./ w2.s;
        wout.e = w2.e.*((wout.s./w2.s).^2);

    else
        error ('Check that the numeric variable is scalar or array with same size as dataset signal')
    end
    
else
    error ('addition of datasets and reals only defined')
end
