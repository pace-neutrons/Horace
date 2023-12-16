function free_memory = calc_free_memory_()
%CALC_FREE_MEMORY_ tries to evaluate the free memory available to
%application by allocating sufficiently large chunk of memory and
%identifying the size of this chunk until it is possible.
%
% Free memory assumed to be memory, which may be allocated.

[~,phys_memory]=sys_memory();
ndata = floor(phys_memory/8); % memory in bytes and I will be allocating doubles

opt = struct('TolX',0.1);
ndata = fzero(@heavi,ndata,opt);
free_memory = floor(0.9*8*ndata);
if free_memory<=0
    free_memory = phys_memory;
    if free_memory <=0
        free_memory  = 1;
    end
end

end

function fv = heavi(np)
try
    data = zeros(np,1);
    fv = -1;
catch
    fv = 10;
end
clear data;
end
