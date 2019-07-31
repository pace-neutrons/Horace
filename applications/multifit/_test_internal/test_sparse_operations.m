n=10000; frac=2/n;


A = make_sparse_matrix (n, frac);
ind=randperm(n,floor(n/3));
tic;
B = A(:,ind);
toc

%----------------------------------------------------
n=1000000; frac=3/n;


A = make_sparse_matrix (n, frac);
B = speye(n);
tic;
C = A + B;
toc



