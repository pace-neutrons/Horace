function [bound_to_res,ratio_res,ok] = binding_resolve (bound_to,ratio)
% Resolve the binding of parameters to the independent parameters by tracing
% back from the unbound parameters to get all parameters that are directly
% or indirectly bound to those unbound parameters


n=numel(bound_to);
bound = (bound_to>0);
if n==0 || all(bound_to(bound_to(bound))==0)
    % Zero length or no chain of binding (every bound parameter is bound to 
    % to an unbound parameter) - no resolving to do
    bound_to_res = bound_to;
    ratio_res = ratio;
    ok = true;
    return
end

% Create sparse arrays of which parameter is bound to which and in what ratio
ir = find(bound);
ic = bound_to(bound);
bound_from = sparse(ir,ic,true,n,n);
ratio_from = sparse(ir,ic,ratio(bound),n,n);

% Get the resolved binding and ratio arrays
ind = find(sum(bound_from,2)==0);  % indicies of unbound parameters
bound_to_res = zeros(n,1);
ratio_res = zeros(n,1);
for i=ind'
    [indb,ratb] = resolve(bound_from,ratio_from,i,1);
    if ~isempty(indb)
        bound_to_res(indb) = i;
        ratio_res(indb) = ratb;
    end
end

% Check that there are no closed loops i.e. that every bound parameter
% resolves to an unbound parameter
if sum(bound_to_res~=0)+numel(ind)==n
    ok = true;
else
    ok = false;
end


%---------------------------------------------------------------------
function [indb,ratb] = resolve(bound_from,ratio_from,ind,rat)
% Find all the parameters bound to a collection of parameters ind

[indb,icol] = find(bound_from(:,ind));
if ~isempty(indb)
    indb_to = ind(icol);
    ratb = rat(icol).*full(ratio_from(sub2ind(size(ratio_from),indb,indb_to)));
    [indb_more,ratio_more] = resolve(bound_from,ratio_from,indb,ratb);
    indb = [indb;indb_more];
    ratb = [ratb;ratio_more];
else
    ratb = [];
end
