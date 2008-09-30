function w = binary_op_manager (w1, w2, binary_op)
% Implement binary arithmetic operations for objects containing a double array.
%
%   if w1, w2 are objects of the same size:
%       - the operation is performed element-by-element
%
%   if one of w1 or w2 is double:
%       - if a scalar, apply to each element of the object double array
%       - if an array of the same size as the object double array, apply
%        element by element
%
%   w1, w2 can be arrays:
%       - if objects have same array sizes, then add element-by-element
%       - if an (n+m)-dimensional array, the inner n dimensions will be
%        combined element by element with the object double array (where
%        n is the dimensionality of the object double array), and the
%        outer m dimensions must match the array size of the array of objects

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
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

    
% Get array sizes of the input arguments 
% ---------------------------------------
if ~isa(w1,'double')
    inner_section1={};
    dim1=size(w1);
    len1=numel(w1);
elseif ~isempty(w1)
    class_ndim=dimensions(w2(1));
    if isscalar(w1)||(class_ndim<2 && length(size(w1))==2 && size(w1,2)==1)...
                   ||(class_ndim>=2 && length(size(w1))==class_ndim)
        dim1=[1,1];
        len1=1;
    elseif (class_ndim<2 && size(w1,2)>1) || (class_ndim>=2 && length(size(w1))>class_ndim)
        dims=size(w1);
        % cell array for array sectioning later on
        inner_section1=cell(1,class_ndim);
        for i=1:class_ndim
            inner_section1{i}=1:dims(i);
        end
        % Outer dimensions
        outer_dims=dims(class_ndim+1:end); % outer dimensions
        if length(outer_dims)==1, dim1=[outer_dims,1]; else dim1=outer_dims; end
        len1=prod(outer_dims);
    else
        error('Invalid double input to first argument')
    end
else
    error('Invalid argument to binary operation - must be non-empty double array')
end
        
if ~isa(w2,'double')
    inner_section2={};
    dim2=size(w2);
    len2=numel(w2);
elseif ~isempty(w2) && isa(w2,'double')
    class_ndim=dimensions(w1(1));
    if isscalar(w2)||(class_ndim<2 && length(size(w2))==2 && size(w2,2)==1)...
                   ||(class_ndim>=2 && length(size(w2))==class_ndim)
        dim2=[1,1];
        len2=1;
    elseif (class_ndim<2 && size(w2,2)>1) || (class_ndim>=2 && length(size(w2))>class_ndim)
        dims=size(w2);
        % cell array for array sectioning later on
        inner_section2=cell(1,class_ndim);
        for i=1:class_ndim
            inner_section2{i}=1:dims(i);
        end
        % Outer dimensions
        outer_dims=dims(class_ndim+1:end); % outer dimensions
        if length(outer_dims)==1, dim2=[outer_dims,1]; else dim2=outer_dims; end
        len2=prod(outer_dims);
    else
        error('Invalid double input to first argument')
    end
else
    error('Invalid argument to binary operation - must be non-empty double array')
end


% Perform binary operation
% --------------------------
if (len1==len2 && len1==1)
    w = binary_op_manager_single (w1, w2, binary_op);
    
elseif (isequal(dim1,dim2) && len1>1)   % same length>1 and same array size
    if isa(w1,classname); w=w1(1); else w=w2(1); end   % template for output
    w = repmat(w,dim1);
    for i=1:len1
        w(i) = binary_op_manager_single (w1(inner_section1{:},i), w2(inner_section2{:},i), binary_op);
    end
    
elseif (len1==1 && len2>1)
    if isa(w1,classname); w=w1(1); else w=w2(1); end   % template for output
    w = repmat(w,dim2);   % create empty output array
    for i=1:len2
        w(i) = binary_op_manager_single (w1, w2(inner_section2{:},i), binary_op);
    end
    
elseif (len1>1 && len2==1)
    if isa(w1,classname); w=w1(1); else w=w2(1); end   % template for output
    w = repmat(w,dim1);   % create empty output array
    for i=1:len1
        w(i) = binary_op_manager_single (w1(inner_section1{:},i), w2, binary_op);
    end
    
else
    error ('Check lengths of array(s) of input arguments')
end

return
