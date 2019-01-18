% For the Cell Linked-List approach to sorting resolution convolution.
% Convert from linear index to subscripted index for a given cell index.

% Inputs:
%   l       the linear index to be converted
%
%   N       the number of cells along each dimension
%
%   span    the span of each dimension (calculated from N if not present)
%
%   Ntot    the total number of cells (calculated from N if not present)
%
%   from    the minimum index for an array (1->MATLAB-like, 0->C-like)
%
% Outputs:
%   s       the subscripted index for the input cell
function s = cll_lin2sub(l,N,span,Ntot,from)
if nargin<5 || isempty(from)
    from = 1; % default to MATLAB-like indexing
end
if nargin<4 || isempty(Ntot)
    Ntot = prod(N);
end
if nargin<3 || isempty(span)
    span = [1; cumprod(N(:))];
    span = span(1:end-1);
end

if any(l<from) || any(l>Ntot-1+from)
    bi = l<1 | 1>Ntot;
    msg = sprintf('%d ',l(bi)); 
    error('linear index %s invalid for %d total cells',msg,Ntot);
end
ni = numel(l);
% make sure l is a row vector (or a single value)
l = permute(l(:),[2,1]); 

% The number of elements we need to account for to get to the input cell
r = l-from; % Make sure we're using C-like indexing
% Allocate the output index vector
s = zeros(numel(N),ni);
% From the largest to smallest spanning dimension
for i=numel(N):-1:1
    % The subscripted index along this dimension is the maximum number 
    % of full spans in the remaining number of elements
    s(i,:) = floor( r/span(i) );
    % Remove this span times this subscript index from remaining element number
    r = r - span(i)*s(i,:);
end
% We want our input and output indexing schemes to match:
s = s + from; 

% % DEBUG testing that we've done this right:
% tst1 = any( s(:) < from );
% tst2 = any( any( s > (N-1+from), 1) );
% tst3 = sum(abs(r))~=0;
% tst4 = any( sum( (s-from).*span ) ~= (l-from) );
% if tst1 || tst2 || tst3 || tst4
%     error('Something has gone wrong converting linear to subscripted index!')
% end

end