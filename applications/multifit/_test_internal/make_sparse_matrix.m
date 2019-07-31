function A = make_sparse_matrix (n, frac)
% Make a sparse n x n matrix that can contain up to n elements, and make
% a fraction frac of those elements have non-zero entries
m = min(max(1,round(frac*n)),n);
i = min(max(1,ceil(n*rand(1,m))),n);
j = min(max(1,ceil(n*rand(1,m))),n);
v = rand(1,m);
A = sparse(i,j,v,n,n);
