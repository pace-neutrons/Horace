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
% $Revision$ ($Date$)

    
% Get array sizes of the input arguments 
% ---------------------------------------
% One of w1 or w2 must be of the class type, because otherwise the method would not have been called
% Only if the other is a double array do we need to do some parsing on the array

if ~isa(w1,'double')
    inner_section1={};
    size1=size(w1);
elseif ~isempty(w1)
    [inner_section1,size1,mess] = array_split (dimensions(w2(1)), size(w1));
    if ~isempty(mess), error(mess), end
else
    error('Invalid argument to binary operation - a double array argument must be non-empty ')
end

if ~isa(w2,'double')
    inner_section2={};
    size2=size(w2);
elseif ~isempty(w2)
    [inner_section2,size2,mess] = array_split (dimensions(w1(1)), size(w2));
    if ~isempty(mess), error(mess), end
else
    error('Invalid argument to binary operation - a double array argument must be non-empty ')
end


% Perform binary operation
% --------------------------
len1=prod(size1);
len2=prod(size2);

if (len1==len2 && len1==1)
    w = binary_op_manager_single (w1, w2, binary_op);
    
elseif ((isequal(size1,size2) || equal_length_vectors(size1,size2)) && len1>1)   % same length>1 and same array size
    if isa(w1,classname);
        w=w1(1);
        size_w=size1;   % need to ensure size matches the class - could have a column or row vector
    else
        w=w2(1);
        size_w=size2;
    end   % template for output
    w = repmat(w,size_w);
    for i=1:len1
        w(i) = binary_op_manager_single (w1(inner_section1{:},i), w2(inner_section2{:},i), binary_op);
    end
    
elseif (len1==1 && len2>1)
    if isa(w1,classname); w=w1(1); else w=w2(1); end   % template for output
    w = repmat(w,size2);   % create empty output array
    for i=1:len2
        w(i) = binary_op_manager_single (w1, w2(inner_section2{:},i), binary_op);
    end
    
elseif (len1>1 && len2==1)
    if isa(w1,classname); w=w1(1); else w=w2(1); end   % template for output
    w = repmat(w,size1);   % create empty output array
    for i=1:len1
        w(i) = binary_op_manager_single (w1(inner_section1{:},i), w2, binary_op);
    end
    
else
    error ('Check lengths of array(s) of input arguments')
end

return

%==================================================================================================
function [inner_section,outer_dims,mess] = array_split (class_nd, sz)
% Split double array into inner and outer sections for binary operations on an array of other objects.
% Deals only with the number of dimensions, but does not check sizes along those dimensions
%
%   >> [inner_section,outer_dims] = array_split (class_ndim, class_sz, sz)
%
%   class_nd        Number of dimensions of the internal array(s) of object (assume class_nd >= 0)
%   sz              Matlab intrinsic SIZE of the double array
%
%   inner_section   Cell array of calss_nd repeats of ':' for array sectioning
%   outer_dims      Outer dimensions that are left over in the double array. If consider that the double
%                  array is an array of arrays, each element being an array with the dimensions of class_dim,
%                  then outer_dims would be the result of the intrinsic Matlab SIZE function on that array.
    
% The trick as always is to handle the case of Matlab vectors or scalar in a consistent fashion as the
% definition of the class dimensionality, strip off the inner dimensions, and then leave the excess dimensions
% (if any) with the correct value as 


% Remove inner dimensions and construct size array of the outer dimensions
% -------------------------------------------------------------------------
if class_nd <= length(sz)    % excess dimensions
    % cell array for array sectioning
    inner_section=cell(1,class_nd);
    for i=1:class_nd
        inner_section{i}=':';
    end
    % Outer dimensions: inner dimensions become 1 and then compress away as many of the inner unity dimensions as can
    % Only if length(sz)>2 can we compress; there we must always have at least a length of 2 after compression
    sz(1:class_nd)=1;
    if length(sz)>2
        ind=min(find(sz~=1));
        if ~isempty(ind)
            ind=min(ind,length(sz)-1);
        else
            ind=length(sz)-1;
        end
        outer_dims=sz(ind:end);
    else
        outer_dims=sz;
    end
    mess='';        
else % not enough dimensions
    inner_section={};
    outer_dims=[];
    mess='Invalid double input to first argument - too few dimensions';
end

%==================================================================================================
function ok = equal_length_vectors (sz1, sz2)
% Test if sizes of two array correspond to vectors of same length - either can be a row or a column vector
%
%   >> ok = equal_length_vectors (sz1, sz2)
%
%   sz1     Matlab intrinsic SIZE of the first array
%   sz2     Matlab intrinsic SIZE of the second array

ok=false;
if (length(sz1)==2 && (sz1(1)==1 || sz1(2)==1)) && (length(sz2)==2 && (sz2(1)==1 || sz2(2)==1))
    if prod(sz1)==prod(sz2)
        ok=true;
    end
end
