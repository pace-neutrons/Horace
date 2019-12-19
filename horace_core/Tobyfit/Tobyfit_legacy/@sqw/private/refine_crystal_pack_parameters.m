function [plist,pfree,pbind]=refine_crystal_pack_parameters (plist_in,pfree_in,pbind_in,opts)
% Alter the foreground function parameter arguments to allow crystal refinement
%
%   >> [plist,pfree,pbind]=refine_crystal_pack_parameters (plist_in,pfree_in,pbind_in,opts)
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
%   opts        Structure with crystal refinement options. assumed to be valid and consistent
%           alatt   Initial lattice parameters
%           angdeg  Initial lattice angles
%           rot     Initial rotation vector (rad)
%           urot    x-axis in r.l.u.
%           vrot    Defines y-axis in r.l.u. (in plane of urot and vrot)
%           pfree   Logical row vector (length=9); true for free parameters
%           fix_alatt_ratio     =true if a,b,c are to be bound
%
% Output:
% -------
%   plist   -|  Updated parameter information to account for additional crystal 
%   pfree    |- refinement options
%   pbind   -|


% Append the refinement parameters (values and whether or not they are free)
plist=cell(size(plist_in));
pfree=cell(size(pfree_in));
opt_pars=[opts.alatt,opts.angdeg,opts.rot];
nforefunc=numel(plist_in);    % number of functions
np=zeros(size(plist_in));
for i=1:nforefunc
    ptmp=multifit_gateway_parameter_get(plist_in{i});
    np(i)=numel(ptmp);  % for later use
    plist{i}=multifit_gateway_parameter_set(plist_in{i}, [ptmp(:)',opt_pars]);
    if i==1
        pfree{i}=[pfree_in{i},opts.pfree];
    else
        pfree{i}=[pfree_in{i},true(1,9)];  % the crystal refinement parameters are bound, so must be floating
    end
end

% Alter the binding
% All the refinement parameters are bound to the first foreground function values
% The only complication is if the  ratios of the lattice parameters are fixed.
b2a=opts.alatt(2)/opts.alatt(1);
c2a=opts.alatt(3)/opts.alatt(1);
pbind=struct('ipbound',{cell(size(pbind_in.ipbound))},'ipboundto',{cell(size(pbind_in.ipboundto))},...
    'ifuncboundto',{cell(size(pbind_in.ifuncboundto))},'pratio',{cell(size(pbind_in.pratio))});
if opts.fix_alatt_ratio
    % For the first foreground function: only a is free
    pbind.ipbound{1}=[pbind_in.ipbound{1};[np(1)+2;np(1)+3]];
    pbind.ipboundto{1}=[pbind_in.ipboundto{1};[np(1)+1;np(1)+1]];
    pbind.ifuncboundto{1}=[pbind_in.ifuncboundto{1};[-1;-1]];
    pbind.pratio{1}=[pbind_in.pratio{1};[b2a;c2a]];
end
% All other foreground functions: parameters are bound to first forground function
for i=2:nforefunc
    pbind.ipbound{i}=[pbind_in.ipbound{i};np(i)+(1:9)'];
    if opts.fix_alatt_ratio
        pbind.ipboundto{i}=[pbind_in.ipboundto{i};[np(1)+1;np(1)+1;np(1)+1];np(1)+(4:9)'];
    else
        pbind.ipboundto{i}=[pbind_in.ipboundto{i};np(1)+(1:9)'];
    end
    pbind.ifuncboundto{i}=[pbind_in.ifuncboundto{i};-ones(9,1)];
    if opts.fix_alatt_ratio
        pbind.pratio{i}=[pbind_in.pratio{i};[1;b2a;c2a];ones(6,1)];
    else
        pbind.pratio{i}=[pbind_in.pratio{i};ones(9,1)];
    end
end
