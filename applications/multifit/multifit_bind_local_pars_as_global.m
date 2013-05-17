function pbind = multifit_bind_local_par_as_global (sz, bind, foreground)
% Bind parameters of a function that is used across all datasets as if they were local
%
%   >> pbind = multifit_bind_local_par (sz, bind)
%
% Input:
% ------
%   sz          Size of the array of datasets
%   bind        Logical array of 0 or 1, indicating which parameters are unbound
%              or bound, respectively
%   forgeound   =true   if the functiona are foreground functions
%               =false if background functions
%
% Output:
% -------
%   pbind       Cell array of binding descriptions

nw=prod(sz);
if nw==0
    error('Check size of data sets array')
elseif nw==1
    pbind={};
else
    ind=find(bind);
    pbind_single={num2cell(num2cell([ind(:),ind(:),(1-2*foreground)*ones(numel(ind),1),ones(numel(ind),1)]),2)'};
    pbind=repmat(pbind_single,sz);
    pbind{1}={};
end
