% For the Cell Linked-List approach to sorting resolution convolution.
% Convert from subscripted index to linear index for a given cell index.

% Inputs:
%     s         the subscripted index to be converted
%     N         the number of cells along each dimension
%     span      the span of each dimension (calculated from N if not present)
%     Ntot      the total number of cells (calculated from N if not present)
%     from      the minimum index for an array (1->MATLAB-like, 0->C-like)
%
% Outputs:
%     l         the linear index equivalent to s
function l=cll_sub2lin(s,N,span,Ntot,from)
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

% The following works for C-like indexing -- so make sure we're using it:
sub = s - from; % C-like subindexing
% The linear index is the sum of the subindex along each dimension times 
% the span of that dimension (but only for C-like indexing)
lin = (sub .* span);
% If we're using MATLAB-like indexing, convert back
l = lin + from;

if l<from || l>(Ntot-1+from)
    error('%d-based linear index %d invalid for %d total cells',from,l,Ntot);
end

end