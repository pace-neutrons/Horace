function [nPt,X,state_out]=cll_generate_points_mc(caller,state_in,nMC,minX,dX,N,span,nC)

if nargin < 8 || isempty(nC)
    nC = prod(N);
end
if nargin < 7 || isempty(span)
    span = cat(1,1,cumprod(N(:)));
    span = span(1:end-1);
end
d = numel(N);
if size(  dX,1) ~= d; error(  'dX should be (%d,1)',d); end
if size(minX,1) ~= d; error('minX should be (%d,1)',d); end

state_out = [];
if caller.reset_state && ~isempty(state_in{1})
    rng(state_in{1});
else
    state_out=rng;
end

% Generate nMC uniformly distributed random points within each cell:
r = rand(d,nC,nMC); 
% Generate the 0-based subscripted indicies for each cell:
s = cll_lin2sub(0:nC-1,N,span,nC,0); % (d,nC)
% In units of (X-minX)/dX the random points are then:
r = bsxfun(@plus, r, s); % (d,nC,nMC)
% So multiply by dX for (X-minX)
r = bsxfun(@times, r, dX); % (d,nC,nMC)*(d,1,1) -> (d,nC,nMC)
% And finally add minX
r = bsxfun(@plus, r, minX); % (d,nC,nMC)+(d,1,1) -> (d,nC,nMC)

% The only thing left to do is to reshape the output:
nPt = nC*nMC;
X = reshape( permute(r,[1,3,2]), d, nPt);

end