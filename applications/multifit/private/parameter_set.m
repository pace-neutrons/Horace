function plist_new = parameter_set (plist, pnew)
% Set the numeric array of parameters in a valid parameter list
%
%   >> p = parameter_set(plist, p)
%
% Input:
% ------
%   plist   Parameter list of the recursive form
%               plist<n> = {@func<n-1>, plist<n-1>, c1<n>, c2<n>,...}
%                        :
%               plist<1> = {@func<0>, plist<0>, c1<1>, c2<1>,...}
%               plist<0> = {p, c1<0>, c2<0>,...}
%                     or =  p
%
%               where p is a numeric vector with at least one element
%
%   pnew    New array to be placed at the root of the parameter list
%
% Output:
% -------
%   plist_new   New parameter list, with the new array reshaped as the
%               existing array if the number of elements are the same.

if iscell(plist) && ~isempty(plist)
    if isa(plist{1},'function_handle') || isa(plist{1},'sw') || isa(sqwfunc,'spinw')
        plist_new={plist{1},parameter_set(plist{2},pnew),plist{3:end}};
    else
        plist_new={reshape_as(pnew,plist{1}),plist{2:end}};
    end
else
    plist_new=reshape_as(pnew,plist);
end

%------------------------------------------------------------------------------
function pnew=reshape_as(pnew,pold)
% Reshape new input array if same number of elements but different shape,
% or if different number of elements, then if a vector reshape to the same
% orientation
if numel(pnew)==numel(pold) &&...
        ~(numel(size(pnew))==numel(size(pold)) && all(size(pnew)==size(pold)))
    pnew=reshape(pnew,size(pold));
elseif numel(pnew)~=numel(pold)
    if iscolvector(pold)
        pnew=pnew(:);
    elseif isrowvector(pold)
        pnew=pnew(:)';
    end
end
