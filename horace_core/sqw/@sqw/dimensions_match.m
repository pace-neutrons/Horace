function [ok,mess,nd_ref,matching]=dimensions_match(w,nd_ref)
% Check that the dimensions of an array of sqw objects are all the same
%
%   >> [ok,mess]=dimensions_match(w)
%   >> [ok,mess]=dimensions_match(w,nref)
%
% Input:
% ------
%   w       sqw object or array of objects
%   nd_ref  [optional] If not given, check all sqw objects in the array
%           have the same dimensionality. If given, check that they match
%           this dimensionality
%
% Output:
% -------
%   ok      True if all have the same dimensionality (and match nref, if given)
%   mess    Empty if ok==true; error message if not
%   nd      Dimensionality
%   matching boolean array containing true, where objects have the same
%           dimensionality and false where the dimensionality is
%           different.
%           If dimensionality is not provided, the comparison occurs over
%           first element of the array of sqw objects

% Original author: T.G.Perring

if nargin==1
    nd_ref=dimensions(w(1));
    nd_ref_given=false;
else
    nd_ref_given=true;
end
matching = arrayfun(@(x)dimensions(x)==nd_ref,w);
if all(matching)
    ok=true;
    mess='';
else
    if numel(w)==1
        mess=sprintf('sqw object is not %d-dimensional',nd_ref);
    else
        if nd_ref_given
            mess=sprintf('Not all elements in the array of sqw objects are %d-dimensional',nd_ref);
        else
            mess='Not all elements in the array of sqw objects have the same dimensionality';
        end
    end

end


