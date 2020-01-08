function mex_Thrower(n,n_total)

if ~exist('n_total','var')
    n_total = n;
end

if (n<=0)
    error('TEST_EXCEPTION:reached','Test exception at level %d',n_total+1)
else
    mex_Thrower(n-1,n_total);
end


