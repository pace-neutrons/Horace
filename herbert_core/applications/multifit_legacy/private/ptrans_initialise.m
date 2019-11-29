function [ok,mess,pf,p_info]=ptrans_initialise(pin,pfree,pbind,bpin,bpfree,bpbind,empty_data)
% Construct a structure with information to transform from a list of free parameter
% values used by the least-squares fitting routine to the parameter values needed
% for function evaluation.
%
%   >> [ok,mess,pf,p_info]=ptrans_initialise(pin,pfree,pbind,bpin,bpfree,bpbind,empty_data)
%
% Input:
% ------
%   pin         Cell array (with same size as array of foreground function handles)
%              of parameter lists for foreground function(s). Can have the general
%              nested form with a numerical array at the root
%
%   pfree       Cell array (with same size as array of foreground function handles)
%              of logical row vectors, where the number of elements of the ith vector
%              equals the number of parameters for the ith function, and with
%              elements =true for free parameters, =false for fixed parameters
%
%   pbind       Structure of cell arrays, one element per foreground function,
%              that define the binding of foreground parameters (see the
%              function pbind_parse for details)
%
%   bpin        -|
%   bpfree       |- The same as above but for background functions
%   bpbind      -|
%
%   empty_data  Logical array, one element per dataset, true where the dataset
%              contains no data.
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
%              The fields are:
%                   Parameter information as single fields
%                   --------------------------------------
%                   pp0     Parameter values, taking account of explicit binding ratios (column vector)
%                   free    Logical array of which parameters are free (does NOT include
%                          parameters bound to a free parameter) (column vector)
%                   bound   Logical array of which parameters are bound to another parameter (column vector)
%                   ib      Parameter index to which a parameter is bound (=0 if not bound) (column vector)
%                   ratio   Ratio of bound parameter to the free parameter (column vector)
% 
%                   Numbers of parameters
%                   --------------------------------------
%                   np      Array of number of parameters for each foreground function
%                         (Array has same size as array of foreground function handles)
%                   nbp     Array of number of parameters for each background function
%                         (Array has same size as array of background function handles)
%                   nptot   Total number of foreground parameters
%                   nbptot  Total number of foreground parameters
%                   npptot  Total number of parameters in foreground and background functions
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
pf_err=[]; p_info_err=struct([]);

% Unpack the pbind structures
ipbound     = pbind.ipbound;
ipboundto   = pbind.ipboundto;
ifuncboundto= pbind.ifuncboundto;
pratio      = pbind.pratio;
ibpbound     = bpbind.ipbound;
ibpboundto   = bpbind.ipboundto;
ibfuncboundto= bpbind.ifuncboundto;
bpratio      = bpbind.pratio;

% Get number of parameters for foreground and background functions
sz_fore=size(pin);
nforefunc=numel(pin);
p=cell(nforefunc,1);
np=zeros(nforefunc,1);
for i=1:nforefunc
    p{i}=parameter_get(pin{i});     % pin has already been checked to be valid
    np(i)=numel(p{i});
end

sz_bkd=size(bpin);
nbkdfunc=numel(bpin);
bp=cell(nbkdfunc,1);
nbp=zeros(nbkdfunc,1);
for i=1:nbkdfunc
    bp{i}=parameter_get(bpin{i});   % bpin has already been checked to be valid
    nbp(i)=numel(bp{i});
end

% Start and end of indexing of functions into a single array of parameter information
nhi=cumsum([np;nbp]);
nlo=[1;nhi(1:end-1)+1];
npptot=nhi(end);

% Make column vectors of parameter values, which are free, bound, bound to
pp0=cell2mat([p;bp]);                   % parameter values
free=cell2mat([pfree(:)',bpfree(:)'])'; % true where parameter is free
bound=false(npptot,1);                  % true if bound to another parameter
boundto=false(npptot,1);                % true if another parameter is bound to this parameter
ib=zeros(npptot,1);                     % parameter indicies to which bound parameters are bound
ratio=zeros(npptot,1);                  % ratios of bound parameters to the bound-to parameters

ippbound=[ipbound(:);ibpbound(:)];
ippboundto=[ipboundto(:);ibpboundto(:)];
ippfuncboundto=[ifuncboundto(:);ibfuncboundto(:)];
for i=1:nforefunc+nbkdfunc
    ippfuncboundto{i}=abs(ippfuncboundto{i})+(ippfuncboundto{i}>0)*nforefunc;  % -nf...-1,1,...nb => nf...1,nf+1...(nf+nb)
end
ppratio=[pratio(:);bpratio(:)];
for i=1:nforefunc+nbkdfunc
    bound(ippbound{i}+nlo(i)-1)=true;
    boundto(ippboundto{i}+nlo(ippfuncboundto{i})-1)=true;
    ib(ippbound{i}+nlo(i)-1)=ippboundto{i}+nlo(ippfuncboundto{i})-1;
    ratio(ippbound{i}+nlo(i)-1)=ppratio{i};
end


% Perform consistency tests of which functions are free and bound
% ---------------------------------------------------------------
% Test that bound parameters do not appear in the bound-to parameter list
bad=bound&boundto;
[ok,mess]=get_bad_parameters_message(bad,sz_fore,sz_bkd,nlo,nhi,'both bound and has another parameter bound to it');
if ~ok, pf=pf_err; p_info=p_info_err; return, end

% Test that bound parameters appear in the free parameter list
% (Parameters that are bound must be allowed to float, otherwise they implicitly fix the parameter to which they are bound
%  and whilst this could be accounted for in the code, it is an unintuitive concept, therefore likely to really be an error,
%  and in any case messy to code)
bad=bound&~free;
[ok,mess]=get_bad_parameters_message(bad,sz_fore,sz_bkd,nlo,nhi,'both fixed and bound to another parameter');
if ~ok, pf=pf_err; p_info=p_info_err; return, end

% Note: we allow parameters to be fixed and have others bound to them


% Get binding ratios, now we have checked pfree and pbind are consisent
% ----------------------------------------------------------------------
ratio_default=pp0(bound)./pp0(ib(bound));   % ratios from the initial parameter values
ratio_given=ratio(bound);                   % ratios from binding descriptions for the bound parameters
no_ratio=isnan(ratio_given);
ratio_given(no_ratio)=ratio_default(no_ratio);
ratio(bound)=ratio_given;

bad=~isfinite(ratio);
[ok,mess]=get_bad_parameters_message(bad,sz_fore,sz_bkd,nlo,nhi,'bound with non-finite ratio to another parameter');
if ~ok, pf=pf_err; p_info=p_info_err; return, end

pp0(bound)=ratio(bound).*pp0(ib(bound));    % recompute starting values of any bound parameters
free(bound)=false;  % remove bound parameters from the list of free parameters


% If reached this point, all is consistent and ratios of bound parameters are finite
% ----------------------------------------------------------------------------------
ok=true;
mess='';
if any(free)
    % Fix floating parameters that cannot affect chi-squared because there are no data points that depend on those parameters
    if exist('nodata','var') && any(empty_data)
        if all(empty_data)
            free=false(size(free));     % no data, so all parameters are fixed
            mess='No data to be fitted; all parameters have been fixed';
            
        else
            % Array of dataset indicies corresponding to each of the parameters (=0 if all datasets depend on a parameter)
            % (Note: nforefunc=1 (global) or ndataset (local); nbkdfunc=1 (global) or ndataset (local)
            dataset=zeros(npptot,1);
            if nforefunc==1
                dataset(nlo(1):nhi(1))=0;
            else
                for i=1:nforefunc
                    dataset(nlo(i):nhi(i))=i;
                end
            end
            if nbkdfunc==1
                dataset(nlo(1+nforefunc):nhi(1+nforefunc))=0;
            else
                for i=1:nbkdfunc
                    dataset(nlo(i)+nforefunc:nhi(i)+nforefunc)=i;
                end
            end
            
            % Get an array of dataset numbers (datasetsort) of those that have a dependency on bound parameters, and lower and upper
            % index arrays into that array (idlo and idhi) such that datasetsort(idlo(i):idhi(i)) gives all datasets that have a
            % dependency on parameter i, if that parameter has one or more others bound to it.
            [ibsort,ix]=sort(ib);       % sorted list of parameter numbers to which parameters are bound
            datasetsort=dataset(ix);    % corresponding dataset indicies
            [ibunique,iblo]=unique(ibsort,'first'); % more than one parameter may be bound to on parameter; get unique list
            [dummy_ib,ibhi]=unique(ibsort,'last');
            if ibunique(1)==0           % zero corresponds to parameters to which no parameters bound
                ibunique=ibunique(2:end);   % list of parameters to which parameters are bound
                iblo=iblo(2:end);           % iblo(i) gives lower index into datasetsort of datasets that depend on bound-to parameter ibunique(i)
                ibhi=ibhi(2:end);           % ibhi(i) gives upper index into datasetsort of datasets that depend on bound-to parameter ibunique(i)
            end
            idlo=zeros(npptot,1); idlo(ibunique)=iblo;
            idhi=zeros(npptot,1); idhi(ibunique)=ibhi;
            
            % If a parameter is free, check that the calculated data points for at least one dataset
            % can (in principle) depend on that parameter. (Note that if the parameter belongs to a global
            % function, then by definition this is satified so long as at least one dataset has data in it)
            unconstrained_parameters=false;
            for i=find(free)'   % i needs to be a row vector
                % if local parameter, and its dataset is empty and it does not have
                % any parameters bound to it, or only parameters from empty datasets
                if dataset(i)>0 && empty_data(dataset(i)) && (idlo(i)==0 || all(datasetsort(idlo(i):idhi(i))))
                    free(i)=false;
                    unconstrained_parameters=true;
                end
            end
            if unconstrained_parameters
                if any(free)
                    mess='One or more free parameters have been fixed because the data cannot depend on them';
                else
                    mess='All parameters have been fixed because the data cannot depend on any of them';
                end
            end
        end
    end
else
    % All parameters are fixed
    mess='All parameters are fixed';
end


% Package arguments that are needed to transform the adjustable parameters into function parameters in a convenient structure
% Create output parameters
% --------------------------
pf=pp0(free);

% Store conversion information useful for single column vector representations of parameter information
p_info=struct;
p_info.pp0=pp0;         % Parameter values, taking account of explicit binding ratios
p_info.free=free;       % Logical array of which parameters are free (does NOT include parameters bound to a free parameter)
p_info.bound=bound;     % Logical array of which parameters are bound to another parameter
p_info.ib=ib;           % Parameter index to which a parameter is bound (=0 if not bound)
p_info.ratio=ratio;     % Ratio of bound parameter to the free parameter

% Numbers of parameters, by function and in total
p_info.np=reshape(np,sz_fore);	% Array of number of parameters for each foreground function
p_info.nbp=reshape(nbp,sz_bkd);	% Array of number of parameters for each background function
p_info.nptot=sum(np);   % Total number of foreground parameters
p_info.nbptot=sum(nbp); % Total number of foreground parameters
p_info.npptot=npptot;   % Total number of parameters in foreground and background functions

% Same information about binding repackaged by function
[fore.p0, bkgd.p0] = array_to_p_bp (pp0, p_info.np, p_info.nbp);            % Cell array of column vectors with parameter values
[fore.pfree, bkgd.pfree] = array_to_p_bp (free, p_info.np, p_info.nbp);     % Cell array of logical column vectors of which parameters are free
[fore.pbound, bkgd.pbound] = array_to_p_bp (bound, p_info.np, p_info.nbp);  % Cell array of logical column vectors of which parameters are bound

fore.ipboundto = cell(sz_fore);
fore.ifuncboundto = cell(sz_fore);
for i=1:nforefunc
    fore.ipboundto{i}=zeros(np(i),1);
    fore.ipboundto{i}(ipbound{i}) = ipboundto{i};       % Feb 2015, changed from: fore.ipboundto{i}(fore.pbound{i}) = ipboundto{i};
    fore.ifuncboundto{i}=zeros(np(i),1);
    fore.ifuncboundto{i}(ipbound{i}) = ifuncboundto{i}; % Feb 2015, changed from: fore.ifuncboundto{i}(fore.pbound{i}) = ifuncboundto{i};
end
bkgd.ipboundto = cell(sz_bkd);
bkgd.ifuncboundto = cell(sz_bkd);
for i=1:nbkdfunc
    bkgd.ipboundto{i}=zeros(nbp(i),1);
    bkgd.ipboundto{i}(ibpbound{i}) = ibpboundto{i};         % Feb 2015, changed from: bkgd.ipboundto{i}(bkgd.pbound{i}) = ibpboundto{i};
    bkgd.ifuncboundto{i}=zeros(nbp(i),1);
    bkgd.ifuncboundto{i}(ibpbound{i}) = ibfuncboundto{i};   % Feb 2015, changed from: bkgd.ifuncboundto{i}(bkgd.pbound{i}) = ibfuncboundto{i};
end
[fore.pratio, bkgd.pratio] = array_to_p_bp (ratio, p_info.np, p_info.nbp);  % Cell array of column vectors of binding ratios for bound parameters

p_info.fore=fore;
p_info.bkgd=bkgd;


%--------------------------------------------------------------------------------------------------
function [p,bp]=array_to_p_bp(pp,np,nbp)
% Convert to cell arrays of column vectors for foreground and background functions
nptot=sum(np(:));
p=reshape(mat2cell(pp(1:nptot),np(:),1),size(np));
bp=reshape(mat2cell(pp(nptot+1:end),nbp(:),1),size(nbp));


%--------------------------------------------------------------------------------------------------
function [ok,mess]=get_bad_parameters_message(bad,sz_fore,sz_bkd,nlo,nhi,mess_str)
% Check if any parameters are bad, and create error message if there are.
if any(bad)
    ok=false;
    npbad=sum(bad);
    ipbad=find(bad,1);
    ifunc=find(ipbad<=nhi,1,'first');   % function index to which first inconsistent parameter belongs
    ipbad=ipbad-nlo(ifunc)+1;           % parameter index within that function
    nforefunc=prod(sz_fore);            % total number of foreground functions
    if ifunc<=nforefunc % one of the foreground parameters
        mess=['Parameter ',num2str(ipbad),' in foreground function ',arraystr(sz_fore,ifunc),' is ',mess_str];
        if npbad==2
            mess=[mess,' (one other parameter too)'];
        elseif npbad>2
            mess=[mess,' (',num2str(npbad-1),' other parameters too)'];
        end
        return
    else
        mess=['Parameter ',num2str(ipbad),' in background function ',arraystr(sz_bkd,ifunc-nforefunc),' is ',mess_str];
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
