function d=xye(w)
% Return a structure containing unmasked x,y,e arrays for an array of IX_dataset_1d objects
%
%   >> d=xye(w)
%
% Fields are:
%   d.x     x values
%           - array same size as y and e (if x one dimensional)
%           - cell array of arrays, one per x dimension (if x is multi-dimensional)
%   d.y     y values
%   d.e     st, deviations
%
% Generic method

% Original author: T.G.Perring

for i=1:numel(w)
    if i==2, d=repmat(d,size(w)); end
    x=sigvar_getx(w(i));
    [s,var,msk]=sigvar_get(w(i));
    d(i).x=x(msk);
    d(i).y=s(msk);
    d(i).e=sqrt(var(msk));
end
