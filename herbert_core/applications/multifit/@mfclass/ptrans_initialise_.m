function [ok_sim, ok_fit, mess, pf, p_info] = ptrans_initialise_ (obj)
% Make a structure to convert independent parameters to full set of parameters
%
%   >> [ok, mess, pf, p_info] = ptrans_initialise_ (obj)
%
% Output:
% -------
%   ok_sim      If input arguments are valid for simulation then = true; if not, =false
%   ok_fit      If input arguments are valid for fitting then = true; if not, =false
%              Note that ok_fit necessarily implies ok_sim.
%   mess        If ~ok_sim, then error message why not possible to simulate
%               If ~ok_fit, then error message why not possible to fit
%   pf          Column vector of free parameter initial values. It is possible
%              that all parameters will be fixed once the empty data sets have
%              been analysed, in which case pf will be empty.
%   p_info      Structure with information needed to transform from a given set
%              of pf to the parameter values needed for function evaluation.
%
%               The fields are:
%
%                   Numbers of parameters
%                   --------------------------------------
%                   np      Array of number of parameters for each foreground function (row vector)
%                   nbp     Array of number of parameters for each background function (row vector)
%                   nptot   Total number of foreground parameters
%                   nbptot  Total number of foreground parameters
%                   npptot  Total number of parameters in foreground and background functions
%
%                   Parameter information as single fields
%                   --------------------------------------
%                   pp0     Parameter values, taking account of explicit binding ratios (column vector)
%                   free    Logical array of which parameters are free and independent (does NOT include
%                          parameters bound to a free parameter) (column vector)
%                   bound   Logical array of which parameters are bound to another parameter (column vector)
%                   ib      Parameter index to which a parameter is bound (=0 if not bound) (column vector)
%                   ratio   Ratio of bound parameter to the free parameter (column vector)
%
%                   Parameter information as cell arrays
%                   --------------------------------------
%                   fore    Structure with foreground parameter information
%                   bkgd    Structure with background parameter information
%
%                   Each of these structures has fields that are cell arrays with same size
%                   as the corresponding function handle array. The fields are:
%                     p0            Cell array of column vectors of parameter values
%                     pfree         Cell array of logical column vectors of free parameter values
%                     pbound        Cell array of logical column vectors of bound parameter values
%                     ipboundto     Cell array of column vectors of parameter indicies to which
%                                   parameters are bound (zeros for parameters that are not bound)
%                     ifuncboundto  Cell array of column vectors of function indicies to which
%                                  parameters are bound (zeros for parameters that are not bound)
%                                  Elements are <0 for foregraound functions, and >0 for
%                                  background functions.
%                     pratio        Cell array of column vectors of binding ratios


% ***
% There are two approaches to resolving free and bound parameters:
% (1) If a fixed parameter is bound to a independent parameter, the independent
%     parameter is forced to become fixed?
% (2) The free/fixed status of the independent parameter overrules the bound
%    parameter's fixed/free status?
% Here we have chosen the latter, that is, being bound takes precedence
% on the grounds that the user ought to have an idea of what are the
% independent parametera, and would be surprised to have any implicit fixing.
% ***


% Original author: T.G.Perring
%
% $Revision:: 839 ($Date:: 2019-12-16 18:18:44 +0000 (Mon, 16 Dec 2019) $)


% Return values if error
% ----------------------
pf_err = []; p_info_err = struct([]);

% Get output arguments
% --------------------
ok_sim = true;
ok_fit = true;

np = obj.np_;
nbp = obj.nbp_;
nptot = sum(np);
nbptot = sum(nbp);
npptot = nptot + nbptot;
if npptot==0 && ok_fit
    ok_fit = false; mess = 'There are no parameters in any of the fitting function(s)';
end

pp0 = [zeros(0,1); cell2mat(arrayfun(@(x)x.p,obj.pin_,'UniformOutput',false))';...     % enforce [0,1] if pin_,bpin_ empty
    cell2mat(arrayfun(@(x)x.p,obj.bpin_,'UniformOutput',false))'];
free = (cell2mat([obj.free_,obj.bfree_])' & ~obj.bound_);   % the variable free means 'independent and floating'
if all(~free) && ok_fit
    ok_fit = false; mess = 'Every parameter is either bound or fixed - therefore no parameters to fit';
end
bound = obj.bound_;
ib = obj.bound_to_res_;

% Get binding ratios
ratio = obj.ratio_res_;
ratio_default = pp0(bound)./pp0(ib(bound)); % ratios from the initial parameter values
ratio_given = ratio(bound);                 % ratios from binding descriptions for the bound parameters
no_ratio = isnan(ratio_given);
ratio_given(no_ratio) = ratio_default(no_ratio);
ratio(bound) = ratio_given;

bad = bound & ~isfinite(ratio);
[ok,mess_tmp] = get_bad_parameters_message(bad,np,nbp,'bound with non-finite ratio to another parameter');
if ~ok && ok_sim
    ok_sim = false; ok_fit = false; mess = mess_tmp;
    pf = pf_err; p_info = p_info_err; return
end
pp0(bound) = ratio(bound).*pp0(ib(bound));  % recompute starting values of any bound parameters


% Determine if any parameters are unconstrained by the data
% ---------------------------------------------------------
if ok_fit   % no point in testing if already not possible to perform a fit
    isdata = cellfun(@(x)any(x(:)), obj.msk_);
    if any(isdata)
        % There are data in at least one of the data sets
        ifun = replicate_iarray([1:numel(np),-1:-1:-numel(nbp)], [np,nbp]);     % function indicies of all parameters
        constrained = false(npptot,1);  % array indicating which parameters are constrained by the data
        if obj.foreground_is_local_
            constrained(ifun>0) = isdata(ifun(ifun>0));
        else
            constrained(ifun==1) = true;    % as there is some data, a parameter of global function is constrained
        end
        if obj.background_is_local_
            constrained(ifun<0) = isdata(abs(ifun(ifun<0)));
        else
            constrained(ifun==-1)=true;     % as there is some data, a parameter of global function is constrained
        end
        
        bound_to_res = obj.bound_to_res_;
        bound_to_res(~bound) = find(~bound);% resolved binding, including the concept of bound-to-self
        constrained_res = accumarray (bound_to_res,constrained,[npptot,1]);
        bad = free & ~constrained_res;
        [ok_fit, mess] = get_bad_parameters_message(bad,np,nbp,'unconstrained by the data because dataset(s) that depend on it are empty or fully masked');
    else
        % There are no data
        ok_fit = false;
        mess = 'No data to be fitted - data sets are empty or all data has been masked';
    end
end

% Same information about binding repackaged by function
% -----------------------------------------------------
[fore.p0, bkgd.p0] = array_to_p_bp (pp0, np, nbp);              % Cell array of column vectors with parameter values
[fore.pfree, bkgd.pfree] = array_to_p_bp (free, np, nbp);       % Cell array of logical column vectors of which parameters are free
[fore.pbound, bkgd.pbound] = array_to_p_bp (bound, np, nbp);    % Cell array of logical column vectors of which parameters are bound

% Note the sign inversion below of function indicies (foreground==negative, background=positive)
% as this was (and remains) the convention used in multifit_lsqr routines
ipboundto = zeros(npptot,1);
ifuncboundto = zeros(npptot,1);
[ipboundto(bound), ifuncboundto(bound)] = ind2parfun (obj.bound_to_res_(bound), np, nbp);
[fore.ipboundto, bkgd.ipboundto] = array_to_p_bp (ipboundto, np, nbp);
[fore.ifuncboundto, bkgd.ifuncboundto] = array_to_p_bp (-ifuncboundto, np, nbp);

[fore.pratio, bkgd.pratio] = array_to_p_bp (ratio, np, nbp);    % Cell array of column vectors of binding ratios for bound parameters


% Return output
% -------------
pf = pp0(free);
p_info = struct('np',np,'nbp',nbp,'nptot',nptot,'nbptot',nbptot,'npptot',npptot,...
    'pp0',pp0,'free',free,'bound',bound,'ib',ib,'ratio',ratio,'fore',fore','bkgd',bkgd);


%--------------------------------------------------------------------------------------------------
function [p,bp]=array_to_p_bp(pp,np,nbp)
% Convert to cell arrays of column vectors for foreground and background functions
nptot=sum(np(:));
p=reshape(vec_to_cell(pp(1:nptot),np(:)),size(np));
bp=reshape(vec_to_cell(pp(nptot+1:end),nbp(:)),size(nbp));


%--------------------------------------------------------------------------------------------------
function [ok,mess]=get_bad_parameters_message(bad,np,nbp,mess_str)
% Check if any parameters are bad, and create error message if there are.
if any(bad)
    ok=false;
    npbad=sum(bad);
    [ipbad,ifuncbad]=ind2parfun(find(bad,1),np,nbp);
    if ifuncbad>0 % one of the foreground parameters
        mess=['Parameter ',num2str(ipbad),' in foreground function ',arraystr(size(np),ifuncbad),' is ',mess_str];
        if npbad==2
            mess=[mess,' (one other parameter too)'];
        elseif npbad>2
            mess=[mess,' (',num2str(npbad-1),' other parameters too)'];
        end
        return
    else
        mess=['Parameter ',num2str(ipbad),' in background function ',arraystr(size(nbp),abs(ifuncbad)),' is ',mess_str];
        if npbad==2
            mess=[mess,' (one other parameter too)'];
        elseif npbad>2
            mess=[mess,' (',num2str(npbad-1),' other parameters too)'];
        end
        return
    end
else
    ok=true;
    mess='';
end

