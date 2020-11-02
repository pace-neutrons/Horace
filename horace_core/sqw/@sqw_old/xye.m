function S=xye(w,null_value)
% Get the bin centres, intensity and error bar for a 1D, 2D, 3D or 4D dataset
%
%   >> S = xye(w)
%   >> S = xye(w, null_value)
%
% Input:
% ------
%   w       sqw object or array of objects (1D, 2D, 3D or 4D)
%   null_value  Numeric value to substitute for the intensity in bins
%           with no data.
%           Default: NaN
%
% Output:
% -------
%   S       Structure with the following fields:
%
%       x   If a 1D sqw object, a column vector with the bin centres
%           Otherwise, a cell array (row vector) of arrays, each array containing the
%           bin centres for the plot axes. Each array of bin centres
%           is a column vector.
%
%       y   n1 x n2 x... array of intensities, where n1 is the number of
%           bins along the first plot axis, n2 the number of bins along
%           the second plot axis etc
%
%       e   n1 x n2 x... array of error bars, where n1 is the number of
%           bins along the first plot axis, n2 the number of bins along
%           the second plot axis etc


if nargin==1
    null_value=NaN;
else
    if ~isnumeric(null_value) || ~isscalar(null_value)
        error('Null value must be a numeric scalar')
    end
end

S=repmat(struct('x',[],'y',[],'e',[]),size(w));
for i=1:numel(w)
    x=w(i).data.p;
    y=w(i).data.s;
    e=sqrt(w(i).data.e);
    empty=~logical(w(i).data.npix);
    
    if numel(x)==1
        x=0.5*(x{1}(2:end)+x{1}(1:end-1));
    else
        for j=1:numel(x)
            x{j}=0.5*(x{j}(2:end)+x{j}(1:end-1));
        end
    end
    y(empty)=null_value;
    e(empty)=0;
    
    S(i).x=x;
    S(i).y=y;
    S(i).e=e;
end
