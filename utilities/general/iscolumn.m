function yes = iscolumn(v)
% True if array is a column vector i.e. n x 1 array with n>=0
yes = numel(size(v))==2 & size(v,2)==1;
