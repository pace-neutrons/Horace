function pbind = multifit_bind_local_pars_as_global (sz, bind, foreground)
% Bind parameters of a function that is used across all datasets as if they were global
%
%   >> pbind = multifit_bind_local_par (sz, bind)
%
% This is a utility function that can be used to simplify the binding of 
% parameters when a local function is used but which is the same for all
% datasets. A common requirement is for some of the parameters to be global
% but others local; this function will create the binding description
% that defines this behaviour during a fit.
%
% Input:
% ------
%   sz          Size of the array of datasets
%   bind        Logical array of 0 or 1, indicating which parameters are unbound
%              (i.e. vary independently) or bound as global (i.e. are equal and
%              vary together for all datasets) respectively
%   forgeound   =true   if the functiona are foreground functions
%               =false if background functions
%
% Output:
% -------
%   pbind       Cell array of binding descriptions
 
 
% Original author: T.G.Perring 
% 
% $Revision:: 830 ($Date:: 2019-04-09 10:03:50 +0100 (Tue, 9 Apr 2019) $) 


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
