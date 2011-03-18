function yes = isrow(v)
% True if array is a row vector i.e. 1 x n array, n>=0.
yes = numel(size(v))==2 & size(v,1)==1;
