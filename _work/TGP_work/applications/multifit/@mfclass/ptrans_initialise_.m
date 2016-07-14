function [ok, mess, pf, p_info] = ptrans_initialise_ (obj)
% Make a structure to convert independent parameters to full set of parameters
%
%   >> [ok, mess, pf, p_info] = ptrans_initialise_ (obj)
%
%
% Output:
% -------
%   ok          =true if input arguments are valid, =false if not
%   mess        Error message if not OK;
%               Warning message if OK, but non-standard situation e.g. no
%              free parameters (so function evaluation is possible, but not fitting)
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
%                   free    Logical array of which parameters are free (does NOT include
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
%                     p0      Cell array of column vectors of parameter values
%                     pfree   Cell array of logical column vectors of free parameter values
%                     pbound  Cell array of logical column vectors of bound parameter values
%                     ipboundto       Cell array of column vectors of parameter indicies to which
%                                    parameters are bound (zeros for parameters that are not bound)
%                     ifuncboundto    Cell array of column vectors of function indicies to which
%                                    parameters are bound (zeros for parameters that are not bound)
%                                    Elements are <0 for foregraound functions, and >0 for
%                                    background functions


% Return values if error
% ----------------------
pf_err = []; p_info_err = struct([]);

% Get output arguments
% --------------------
np = obj.np_;
nbp = obj.nbp_; 
nptot = sum(np);
nbptot = sum(nbp);
npptot = nptot + nbptot;

pp0 = [cell2mat(cellfun(@parameter_get,obj.pin_,'UniformOutput',false)');...
    cell2mat(cellfun(@parameter_get,obj.bpin_,'UniformOutput',false)')];
free = (obj.free_ & ~obj.bound_);
bound = obj.bound_;
ib = obj.bound_to_;

% Get binding ratios
ratio = obj.ratio_;
ratio_default = pp0(bound)./pp0(ib(bound)); % ratios from the initial parameter values
ratio_given = ratio(bound);                 % ratios from binding descriptions for the bound parameters
no_ratio = isnan(ratio_given);
ratio_given(no_ratio) = ratio_default(no_ratio);
ratio(bound) = ratio_given;

bad = bound & ~isfinite(ratio);
[ok,mess] = get_bad_parameters_message(bad,np,nbp,'bound with non-finite ratio to another parameter');
if ~ok
    pf = pf_err; p_info = p_info_err; return
end


% Determine if any parameters are unconstrained by the data
% ---------------------------------------------------------
nodata = cellfun(@(x)all(~x(:)), obj.msk_);
if ~all(nodata)
    [irow, icol, ind] = find(obj.bound_from_ + speye(size(npptot)));   % Array of bound parameter indicies, including self
    [~, ifun] = ind2parfun (ind, np, nbp);
    constrained = false(size(ifun));
    if obj.foreground_is_local_
        constrained(ifun>0) = ~nodata(ifun>0);
    else
        constrained(ifun==1) = true;   % as there is some data, a parameter of global function is constrained
    end
    if obj.background_is_local_
        constrained(ifun<0) = ~nodata(ifun<0);
    else
        constrained(ifun==-1)=true;    % as there is some data, a parameter of global function is constrained
    end
    constrained = sparse(irow,icol,double(constrained),npptot,npptot);
    constrained = full(sum(constrained,1)>0)';  % true if parameter depends on the data
    bad = free & ~constrained;
    [ok,mess] = get_bad_parameters_message(bad,np,nbp,'unconstrained by the data because datset that depend on it are empty or masked');
    if ~ok
        pf = pf_err; p_info = p_info_err; return
    end
else
    ok = false;
    mess = 'No data to be fitted - data sets are empty or all data has been masked';
    pf = pf_err; p_info = p_info_err; return
end


% Return output
% -------------
pf = pp0(free);
p_info = struct('np',np,'nbp',nbp,'nptot',nptot,'nbptot',nbptot,'npptot',npptot,...
    'pp0',pp0,'free',free,'bound',bound,'ib',ib,'ratio',ratio);



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
