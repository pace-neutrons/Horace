function [ok,mess,nd_ref]=dimensions_match(w,nd_ref)
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
%   ok      True if all have the smae dimensionality (and match nref, if given)
%   mess    Empty if ok==true; error message if not
%   nd      Dimensionality

% Original author: T.G.Perring
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)

if nargin==1
    nd_ref=dimensions(w(1));
    nd_ref_given=false;
else
    nd_ref_given=true;
end

for i=1:numel(w)
    if dimensions(w(i))~=nd_ref
        ok=false;
        if numel(w)==1
            mess=['sqw object is not ',num2str(nd_ref),'-dimensional'];
        else
            if nd_ref_given
                mess=['Not all elements in the array of sqw objects are ',num2str(nd_ref),'-dimensional'];
            else
                mess='Not all elements in the array of sqw objects have the same dimensionality';
            end
        end
        return
    end
end

ok=true;
mess='';
