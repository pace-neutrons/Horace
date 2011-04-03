function [ok,mess,pf,p_info]=ptrans_create(pin,pfree,ipbind,ipfree,ifuncbind,rpbind,...
                                             bpin,bpfree,ibpbind,ibpfree,ibfuncbind,rbpbind,nodata)
% Construct a structure with information to transform from a list of free parameter
% values used by the least-squares fitting routine to the parameter values needed
% for function evaluation.
%
%   >> [ok,mess,pf,p_info] = ptrans_create (pin,pfree,ipbind,ipfree,ifuncbind,rpbind,...
%                                             bpin,bpfree,ibpbind,ibpfree,ibfuncbind,rbpbind)
%
%   pf  free parameter initial values
%   p_info  Structure with information needed to transform from a given set of pf to
%           the parameter values needed for function evaluation

ok=false;
pf=[]; p_info=struct([]);

% Get number of parameters for global and background cross-section functions
pp=parameter_get(pin); % get numerical vector
np=numel(pp);
bp=cell(numel(bpin),1);
nbp=zeros(numel(bpin),1);
for i=1:numel(nbp)
    bp{i}=parameter_get(bpin{i});
    nbp(i)=numel(bp{i});
end

% Indexing of functions into a single array of parameter information
% ind=1  is global function, ind=2=first background function etc
nhi=[np;cumsum(nbp(:))+np];
nlo=nhi-[np;nbp(:)]+1;
nptot=nhi(end);

% Get list of indicies of parameters that are bound
p=zeros(nptot,1);           % parameter value
free=false(nptot,1);        % true if a free parameter
bound=false(nptot,1);       % true if bound to another parameter
ib=zeros(nptot,1);          % parameter index to which bound
boundto=false(nptot,1);     % true if another parameter is bound to this parameter
ratio=zeros(nptot,1);

p(1:np)=pp;
free(1:np)=pfree;
bound(ipbind)=true;
ib(ipbind)=ipfree+nlo(ifuncbind+1)-1;
boundto(ipfree+nlo(ifuncbind+1)-1)=true;
ratio(ipbind)=rpbind;
for i=1:numel(nbp)
    p(nlo(i+1):nhi(i+1))=bp{i};
    free(nlo(i+1):nhi(i+1))=bpfree{i};
    bound(ibpbind{i}+nlo(i+1)-1)=true;
    ib(ibpbind{i}+nlo(i+1)-1)=ibpfree{i}+nlo(ibfuncbind{i}+1)-1;
    boundto(ibpfree{i}+nlo(ibfuncbind{i}+1)-1)=true;
    ratio(ibpbind{i}+nlo(i+1)-1)=rbpbind{i};
end

% Test that bound parameters do not appear in the bound-to parameter list
if any(bound&boundto)
    ind=find(bound&boundto,1);
    if ind<=np  % one of the global parameters
        mess=['Parameter ',num2str(ind),' in the fitting function is both bound and has another parameter bound to it'];
        return
    else
        iback=find(ind>=nlo,1,'last')-1; % recall nlo has background function index offset by one
        ind=ind-nlo(iback+1)+1;
        mess=['Parameter ',num2str(ind),' in background function ',arraystr(size(nbp),iback),' is both bound and has another parameter bound to it'];
        return
    end
end

% Test that bound parameters appear in the free parameter list
% (Parameters that are bound must be allowed to float, otherwise they implicitly fix the parameter to which they are bound
%  and whilst this could be accounted for in the code, it is unintuitive)
if any(bound&~free)
    ind=find(bound&~free,1);
    if ind<=np  % one of the global parameters
        mess=['Parameter ',num2str(ind),' in the fitting function is both fixed and bound to another parameter'];
        return
    else
        iback=find(ind>=nlo,1,'last')-1; % recall nlo has background function index offset by one
        ind=ind-nlo(iback+1)+1;
        mess=['Parameter ',num2str(ind),' in background function ',arraystr(size(nbp),iback),' is both fixed and bound to another parameter'];
        return
    end
end

% At this point the binding and freeing of parameters should be consistent. Now get the binding ratios
ratio_default=p(bound)./p(ib(bound));   % ratios from initial parameters for the bound parameters
ratio_given=ratio(bound);               % ratios from binding descriptions for the bound parameters
no_ratio=isnan(ratio_given);            
ratio_given(no_ratio)=ratio_default(no_ratio);
ratio(bound)=ratio_given;

if any(~isfinite(ratio))
    ind=find(~isfinite(ratio),1);
    if ind<=np  % one of the global parameters
        mess=['Parameter ',num2str(ind),' in the fitting function is bound with non-finite ratio to another parameter'];
        return
    else
        iback=find(ind>=nlo,1,'last')-1; % recall nlo has background function index offset by one
        ind=ind-nlo(iback+1)+1;
        mess=['Parameter ',num2str(ind),' in background function ',arraystr(size(nbp),iback),' is bound with non-finite ratio to another parameter'];
        return
    end
end

% Package arguments that are needed to transform the adjustable parameters into function parameters into a convenient structure
free(bound)=false;  % Remove bound parameters from the list of free parameters
p(bound)=ratio(bound).*p(ib(bound));     % recompute starting values of any bound parameters


% Fix floating parameters that cannot affect chi-squared because there is are no data points that depend on those parameters.
if exist('nodata','var') && any(nodata)
    if all(nodata)
        free=false(size(free));     % no data, so all parameters are fixed
        disp(' ')
        disp('WARNING: No data to be fitted; all parameters are fixed')
        disp(' ')
    else
        dataset=zeros(nptot,1);     % hold dataset index for the parameter (=0 for global parameters)
        for i=1:numel(nbp)
            dataset(nlo(i+1):nhi(i+1))=i;
        end
        [ibsortup,ix]=sort(ib);     % sorted list of parameter numbers to which parameters are bound
        datasetsort=dataset(ix);    % corresponding dataset indicies

        ibsortdown=sort(ib,'descend');
        [ibunique,ibhi]=unique(ibsortup);
        [dummy,iblo]=unique(ibsortdown);
        iblo=numel(ib)+1-iblo;
        if ibunique(1)==0
            ibunique=ibunique(2:end);   % list of parameters to which parameters are bound
            iblo=iblo(2:end);           % lower limit of array dataset to which a parameter is bound
            ibhi=ibhi(2:end);           % upper limit of array dataset to which a parameter is bound
        end
        iblo_all=zeros(nptot,1); iblo_all(ibunique)=iblo;
        ibhi_all=zeros(nptot,1); ibhi_all(ibunique)=ibhi;

        unconstrained_parameters=false;
        for i=find(free)'   % i needs to be a row vector
            % if background parameter, and its dataset is empty and it does not have any parameters bound to it from non-empty datasets
            if i>np && nodata(dataset(i)) && (iblo_all(i)==0 || all(datasetsort(iblo_all(i):ibhi_all(i))))
                free(i)=false;
                unconstrained_parameters=true;
            end
        end
        if unconstrained_parameters
            disp(' ')
            disp('WARNING: One or more free background parameters have been fixed because the data does not depend on them')
            disp(' ')
        end
    end
end


% Create output parameters
% --------------------------
ok=true;
mess='';
pf=p(free);

% Store conversion information useful for single column vector representations of parameter information
p_info=struct;
p_info.pp0=p;           % initial parameter values, taking account of explicit binding ratios
p_info.free=free;       % logical array of which are free (does NOT include parameters bound to a free parameter)
p_info.bound=bound;     % logical array of which parameters are bound to another
p_info.ib=ib;           % parameter index to which a parameter is bound (=0 if not bound)
p_info.ratio=ratio;     % ratio of bound parameter to the free parameter

% Store the same information in form suitable for function index reference
% (Note that p0, bp0 are not necessarily the same as pin, bpin, because the binding ratio may have been explicitly provided)
nbp=reshape(nbp,size(bpin));  % need to reshape, as we constructed nbp as a column vector for some matlab intrinsics to work as we wanted
[p_info.p0, p_info.bp0] = array_to_p_bp (p, np, nbp);
[p_info.pfree, p_info.bpfree] = array_to_p_bp (free, np, nbp);
[p_info.pbound, p_info.bpbound] = array_to_p_bp (bound, np, nbp);
p_info.ipb = zeros(1,np);
p_info.ipfunc = zeros(1,np);
p_info.ipb(p_info.pbound) = ipfree;
p_info.ipfunc(p_info.pbound) = ifuncbind;
p_info.ibpb = cell(size(nbp));
p_info.ibpfunc = cell(size(nbp));
for i=1:numel(nbp)
    p_info.ibpb{i}(p_info.bpbound{i}) = ibpfree{i};
    p_info.ibpfunc{i}(p_info.bpbound{i}) = ibfuncbind{i};
end
[p_info.pratio, p_info.bpratio] = array_to_p_bp (ratio, np, nbp);

% Store useful parameters
p_info.np=np;
p_info.nbp=nbp;
p_info.nptot=nptot;
p_info.npfree=numel(pf);


%-------------------------------
function [p,bp]=array_to_p_bp(pp,np,nbp)
% Convert to row vector for global function and cell array of row vectors for background functions
p=pp(1:np)';
bp=mat2cell(pp(np+1:end)',1,nbp(:)');
bp=reshape(bp,size(nbp));
