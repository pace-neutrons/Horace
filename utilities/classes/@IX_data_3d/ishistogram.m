function status=ishistogram(w,n)
% Return array containing true or false depending on dataset being histogram or point
%
%   >> status=ishistogram(w)    % array [2,size(w)] with true/false for each of the two axes
%   >> status=ishistogram(w,n)  % array with size of w for the nth axis, n=1 or 2

% Check axis index
nd = w.ndim();
if nargin>1
    % Just one axis being tested
    if ~(isnumeric(n) && isscalar(n) && (n>=1||n<=nd))
        error('IX_dataset:invalid_argument',...
            'Invalid axis index %d for %d-dimensional object',n,nd);
    end   
    status  = arrayfun(@(x)(numel(x.xyz_{n}) ~= size(x.signal_,n)),w);    
    status  = status';
else
    status  = arrayfun(@elem_comp,w,'UniformOutput',false);
    status = [status{:}];
    status = reshape(status,[nd,size(w)]);
end


function comp = elem_comp(x)
comp = [numel(x.xyz_{1}),numel(x.xyz_{2}),numel(x.xyz_{3})] ~= size(x.signal_);
