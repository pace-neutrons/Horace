function [bound_to_res,ratio_res,ok] = binding_resolve (bound_to,ratio)
% Resolve the binding of parameters to the independent parameters
%
%   >> [bound_to_res,ratio_res,ok] = binding_resolve (bound_to,ratio)
%
% Input:
% ------
%   bound_to        Column vector where bound_to(i) is the parameter index
%                  to which the ith parameter is bound. If the ith parameter
%                  is unbound then bound_to(i)=0
%   ratio           Ratio of the ith parameter to the value of the parameter
%                  to which it is bound. If the ith parameter is unbound then
%                  bound_to(i) = NaN
%
% Output:
% -------
%   bound_to_res    Column vector where bound_to_res(i) is the parameter
%                  index of the unbound parameter to which the ith parameter
%                  is ultimately bound (0 if unbound)
%   ratio_res       Corresponding ratio of parameter values
%   ok              True if all parameter resolve to an unbound parameter
%                  or false if there is one or more closed loops of bindings


% Original author: T.G.Perring
%
% $Revision:: 832 ($Date:: 2019-08-11 23:25:59 +0100 (Sun, 11 Aug 2019) $)


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
% The reason this needs to be sparse is that we want these to be square
% matricies so that we can perform row and column operations (which means
% of size n^2), but we know that only n entries are non-zero (so sparse
% representation is efficient)
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
% Find all the parameters bound to a collection of unbound parameters ind by
% recursively tracing back from those parameters to get all parameters that 
% are directly or indirectly bound to those unbound parameters

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
