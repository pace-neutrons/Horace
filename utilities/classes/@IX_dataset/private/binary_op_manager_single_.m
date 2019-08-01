function wout = binary_op_manager_single_(w1,w2,binary_op,class_name)
% Implement binary operator for objects with a signal and a variance array.

% Generic method for binary operations on classes that
%   (1) have methods to set, get and find size of signal and variance arrays:
%           >> sz = sigvar_size(obj)
%           >> w = sigvar(obj)          % w is sigvar object (has fields w.s, w.e)
%           >> obj = sigvar_set(obj,w)  % w is sigvar object
%   (2) have dimensions method that gives the dimensionality of the double array
%           >> nd = dimensions(obj)
%   (3) have private function that returns class name
%           >> name = classname     % no argument - gets called by its association with the class

% Original author: T.G.Perring


if ~isa(w1,'double') && ~isa(w2,'double')
    if isequal(sigvar_size(w1),sigvar_size(w2))
        if isa(w1,class_name), wout = w1; else, wout = w2; end
        result = binary_op(sigvar(w1), sigvar(w2));
        wout = sigvar_set(wout,result);
    else
        error ('Sizes of signal arrays in the objects are different')
    end
    
elseif ~isa(w1,'double') && isa(w2,'double')
    if isscalar(w2) || isequal(sigvar_size(w1),size(w2))
        wout = w1;
        result = binary_op(sigvar(w1), sigvar(w2,[]));
        wout = sigvar_set(wout,result);
    else
        error ('Check that the numeric variable is scalar or array with same size as object signal')
    end
    
elseif isa(w1,'double') && ~isa(w2,'double')
    if isscalar(w1) || isequal(sigvar_size(w2),size(w1))
        wout = w2;
        result = binary_op(sigvar(w1,[]), sigvar(w2));
        wout = sigvar_set(wout,result);
    else
        error ('Check that the numeric variable is scalar or array with same size as object signal')
    end
    
else
    error ('binary operations between objects and doubles only defined')
end
