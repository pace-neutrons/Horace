function argout = ndgridcell(argin)
% Version of ndgrid with input and output arguments each a single cell array.
% Exactly the same as ndgrid except that the input argument is a single cell array
% of the input arguments, argin{1}=x1, argin{2}=x2 etc., and the output is a
% single cell array argout{1}=X1, argout{2}=X2 etc.
%
% The only difference is that the case of only one array in the input cell is
% not meaningless, because in ndgrid the number of output arguments is used to
% determine the sise of the output arrays.
%
% See the help for ndgrid for more details.

% Taken from smoothn, downloaded from Matlab central on 2 Jan 2007

if length(argin)==1, error('Must have at least two arrays in input cell'), end
nin = length(argin);
nout = nin;

for i=nin:-1:1,
  argin{i} = full(argin{i}); % Make sure everything is full
  siz(i) = prod(size(argin{i}));
end
if length(siz)<nout, siz = [siz ones(1,nout-length(siz))]; end

argout = cell(1,nout);
for i=1:nout,
  x = argin{i}(:); % Extract and reshape as a vector.
  s = siz; s(i) = []; % Remove i-th dimension
  x = reshape(x(:,ones(1,prod(s))),[length(x) s]); % Expand x
  argout{i} = permute(x,[2:i 1 i+1:nout]);% Permute to i'th dimension
end