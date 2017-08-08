function status=ishistogram(w,n)
% Return array containing true or false depending on dataset being histogram or point
%
%   >> status=ishistogram(w)    % array [2,size(w)] with true/false for each of the two axes
%   >> status=ishistogram(w,n)  % array with size of w for the nth axis, n=1 or 2

% Check axis index
nd = w.ndim();
if nargin>1
    % Just one axis being tested
    if ~(isnumeric(n) && isscalar(n) && (n==1))
        error('IX_dataset:invalid_argument',...
            'Invalid axis index %d for %d-dimensional object',n,nd);
    end
end
status  = arrayfun(@(x)(numel(x.xyz_{1}) ~= size(x.signal_,1)),w);
status  = status';

