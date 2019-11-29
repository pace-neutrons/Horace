function d=xye(w)
% Return a structure containing unmasked x,y,e arrays for an array of IX_dataset_3d objects
%
%   >> d=xye(w)
%
% Fields are:
%   d.x     x values: a cell array of arrays, one for each x dimension
%   d.y     y values
%   d.e     st, deviations
%
% Generic method

% Original author: T.G.Perring

for i=1:numel(w)
    if i==2, d=repmat(d,size(w)); end
    x=sigvar_getx(w(i));
    [s,var,msk]=sigvar_get(w(i));
    for j=1:numel(x)
        d(i).x{j}=x{j}(msk);
    end
    d(i).y=s(msk);
    d(i).e=sqrt(var(msk));
end
