function [plist,pfree,pbind]=refine_moderator_pack_parameters (plist_in,pfree_in,pbind_in,opts)
% Alter the foreground function parameter arguments to allow moderator refinement
%
%   >> [plist,pfree,pbind]=refine_moderator_pack_parameters (plist_in,pfree_in,pbind_in,opts)
%
% Input:
% ------
%   plist_in    Cell array of parameter lists, one per foreground function
%
%   pfree_in    Cell array of logical row vectors indicating which parameters are free
%
%   pbind_in    Structure containing binding information as returned by multifit_gateway:
%           ipbound     Cell array of column vectors of indicies of bound parameters,
%                      one vector per function
%           ipboundto   Cell array of column vectors of the parameters to which those
%                      parameters are bound, one vector per function
%           ifuncboundto  Cell array of column vectors of single indicies of the functions
%                       corresponding to the free parameters, one vector per function. The
%                       index is ifuncfree(i)<0 for foreground functions, and >0 for
%                       background functions.
%           pratio      Cell array of column vectors of the ratios (bound_parameter/free_parameter),
%                      if the ratio was explicitly given. Will contain NaN if not (the
%                      ratio will be determined from the initial parameter values). One
%                      vector per function.
%
%   opts        Structure with moderator refinement options. assumed to be valid and consistent
%           pulse_model Name of moderator pulse shape model
%           pp_init     Initial pulse shape parameters (row vector)
%           pp_free     Logical row vector of zeros and ones
%
% Output:
% -------
%   plist   -|  Updated parameter information to account for additional moderator
%   pfree    |- refinement options
%   pbind   -|


% Append the refinement parameters (values and whether or not they are free)
plist=cell(size(plist_in));
pfree=cell(size(pfree_in));
nforefunc=numel(plist_in);    % number of functions
np=zeros(size(plist_in));
npmod=numel(opts.pp_init);
for i=1:nforefunc
    ptmp=multifit_gateway_parameter_get(plist_in{i});
    np(i)=numel(ptmp);  % for later use
    plist{i}=multifit_gateway_parameter_set(plist_in{i}, [ptmp(:)',opts.pp_init]);
    if i==1
        pfree{i}=[pfree_in{i},opts.pp_free];
    else
        pfree{i}=[pfree_in{i},true(1,npmod)];  % the moderator refinement parameters are bound, so must be floating
    end
end

% Alter the binding
% All the refinement parameters are bound to the first foreground function values
pbind=struct('ipbound',{cell(size(pbind_in.ipbound))},'ipboundto',{cell(size(pbind_in.ipboundto))},...
    'ifuncboundto',{cell(size(pbind_in.ifuncboundto))},'pratio',{cell(size(pbind_in.pratio))});
for i=2:nforefunc
    pbind.ipbound{i}=[pbind_in.ipbound{i};np(i)+(1:npmod)'];
    pbind.ipboundto{i}=[pbind_in.ipboundto{i};np(1)+(1:npmod)'];
    pbind.ifuncboundto{i}=[pbind_in.ifuncboundto{i};-ones(npmod,1)];
    pbind.pratio{i}=[pbind_in.pratio{i};ones(npmod,1)];
end
