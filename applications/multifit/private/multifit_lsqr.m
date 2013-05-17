function [p_best,sig,cor,chisqr_red,converged,ok,mess]=multifit_lsqr(w,xye,func,bkdfunc,pin,bpin,pfin,pinfo,listing,fcp,perform_fit)

% T.G.Perring Jan 2009:
% ------------------------
% Generalise to arbitrary data objects which have a certain set of methods defined on them (see
% multifit.m for details)
%
% T.G.Perring 11-Jan-2007:
% ------------------------
% Core Levenberg-Marquardt minimisation method inspired by speclsqr.m from spec1d, but massively
% edited to make more memory efficient, remove redundant code, and especially rewrite the *AWFUL*
% estimation of errors on the parameter values (which needed a temporary
% array of size m^2, where m is the number of data values - 80GB RAM
% for m=100,000!). The error estimates were also a factor sqrt(ndat/(ndat-npfree))
% too large - as determined by comparing with analytical result for fitting to
% a straight line, from e.g. G.L.Squires, Practical Physics, (CUP ~1980). The
% current routine gives correct result.
%
% Previous history:
% -----------------
% Version 3.beta
% Levenberg-Marquardt nonlinear regression of f(x,p) to y(x)
% Richard I. Shrager (301)-496-1122
% Modified by A.Jutan (519)-679-2111
% Modified by Ray Muzic 14-Jul-1992

p_best=pfin;
sig=zeros(1,numel(pfin));
cor=zeros(numel(pfin));
chisqr_red=0;
converged=false;
ok=true;
mess='';

% Clean the function evaluation routine of buffered results to avoid any conflicts
multifit_lsqr_func_eval

% Package data into a single column vector, and also 1/(error_bar)
yval=cell(size(w));
wt=cell(size(w));
for i=1:numel(w)
    if xye(i)   % xye triple - we have already masked all unwanted points
        yval{i}=w{i}.y;
        wt{i}=1./w{i}.e;
    else        % a different data object: get data to be fitted
        [yval{i},wt{i},msk]=sigvar_get(w{i});
        yval{i}=yval{i}(msk);         % remove the points that we are told to ignore
        wt{i}=1./sqrt(wt{i}(msk));
    end
    yval{i}=yval{i}(:);  	% make a column vector
    wt{i}=wt{i}(:);         % make a column vector
end
yval=cell2mat(yval(:));     % one long column vector
wt=cell2mat(wt(:));

% Check that there are more data points than free parameters
nval=numel(yval);
npfree=numel(pfin);
nnorm=max(nval-npfree,1);   % we allow for the case nval=npfree
if nval<npfree
    ok=false; mess='Number of data points must be greater than or equal to the number of free parameters'; return
end

% Listing to screen
if ~exist('listing','var'), listing=0; end
if isempty(listing), listing=0; end
    
% Catch case of simple evaluation of chi-squared
if ~perform_fit
    if listing>2, disp(' Function evaluation:'), end
    f=multifit_lsqr_func_eval(w,xye,func,bkdfunc,pin,bpin,pfin,pinfo,false,listing);
    resid=wt.*(yval-f);
    
    c_best=resid'*resid; % Un-normalised chi-squared
    chisqr_red = c_best/nnorm;
        
else
    % Set fit control parameters
    if ~exist('fcp','var')
        fcp=[0.0001 20 0.001];
    end
    dp=fcp(1);      % derivative step length
    niter=fcp(2);   % maximum number of iterations
    tol=fcp(3);     % convergence criterion
    if abs(dp)<1e-12
        ok=false; mess='Derivative step length must be greater or equal to 10^-12'; return
    end
    if niter<0
        ok=false; mess='Number of iterations must be >=0'; return
    end
    
    % Output to command window
    if listing~=0, fit_listing_header(listing,niter); end
    
    % Starting values of parameters and function values
    if listing>2, disp(' '), disp(' Function evaluation at starting parameter values:'), end
    f=multifit_lsqr_func_eval(w,xye,func,bkdfunc,pin,bpin,pfin,pinfo,true,listing);
    resid=wt.*(yval-f);
    
    p_best=pfin; % Best values for parameters at start
    f_best=f;    % Function values at start
    c_best=resid'*resid; % Un-normalised chi-squared
    
    lambda=1;
    lambda_table=[1e1 1e1 1e2 1e2 1e2 1e2];
    
    % Iterate to find best solution
    converged=false;
    max_rescale_lambda=0;
    for iter=1:niter
        if listing~=0, fit_listing_iteration_header(listing,iter); end
        % Single value decomposition of
        resid=wt.*(yval-f_best);
        jac=multifit_dfdpf(w,xye,func,bkdfunc,pin,bpin,p_best,pinfo,f_best,dp,listing);
        nrm=zeros(npfree,1);
        for j=1:npfree
            jac(:,j)=wt.*jac(:,j);
            nrm(j)=jac(:,j)'*jac(:,j);
            if nrm(j)>0,
                nrm(j)=1/sqrt(nrm(j));
            end;
            jac(:,j)=nrm(j)*jac(:,j);
        end;
        [jac,s,v]=svd(jac,0);
        s=diag(s);
        g=jac'*resid;
        % Compute change in parameter values.
        % If does not improve chisqr to less than the goal value, then alter
        % the Levenberg-Marquardt parameter until it does (up to a maximum
        % number of times).
        if tol>0
            c_goal=(1-tol)*c_best;  % Goal for improvement in chisqr
        else
            c_goal=c_best-abs(tol);
        end
        lambda=lambda/10;
        for itable=1:numel(lambda_table)
            se=sqrt((s.*s)+lambda);
            gse=g./se;
            p_chg=((v*gse).*nrm);   % compute change in parameter values
            if (any(abs(p_chg)>0))  % if any change in the parameters
                p=p_best+p_chg;
                if listing>2, disp(' Function evaluation after stepping parmeters:'), end
                f=multifit_lsqr_func_eval(w,xye,func,bkdfunc,pin,bpin,p,pinfo,true,listing);
                resid=wt.*(yval-f);
                c=resid'*resid;
                if c<c_best
                    p_best=p;
                    f_best=f;
                    c_best=c;
                    break;
                end
                if listing~=0, fit_listing_iteration(listing, iter, c/nnorm, lambda, p); end
            end;
            if itable==numel(lambda_table) % Gone to end of table without improving chisqr
                max_rescale_lambda=1;
                break;
            end
            % Chisqr didn't improve - increase lambda and recompute step in parameters
            lambda = lambda*lambda_table(itable);
        end
        
        % Output to command window
        if listing~=0, fit_listing_iteration(listing, iter, c_best/nnorm, lambda, p_best); end
        
        % if chisqr lowered, but not to goal, so converged; or chisqr==0 i.e. perfect fit; then exit loop
        if (c_best>c_goal) || (c_best==0)
            converged=true;
            break;
        end
        
        % If multipled lambda to limit of the table, give up
        if  max_rescale_lambda==1
            converged=false;
            break
        end
        
    end
    
    % Wrap up for exit from fitting routine
    if converged
        chisqr_red = c_best/nnorm;
        % Calculate covariance matrix
        if listing>2, disp(' '), disp(' Fit converged; estimate errors and covariance matrix'), end
        jac=multifit_dfdpf(w,xye,func,bkdfunc,pin,bpin,p_best,pinfo,f_best,dp,listing);
        for j=1:npfree
            jac(:,j)=wt.*jac(:,j);
        end;
        [jac,s,v]=svd(jac,0);
        s=repmat((1./diag(s))',[npfree,1]);
        v=v.*s;
        cov=chisqr_red*(v*v');  % true covariance matrix;
        sig=sqrt(diag(cov));
        tmp=repmat(1./sqrt(diag(cov)),[1,npfree]);
        cor=tmp.*cov.*tmp';
        if listing~=0, fit_listing_final(listing, p_best, sig, cor, pinfo); end
    else
        chisqr_red = c_best/nnorm;
        ok=true;
        mess='WARNING: Convergence not achieved';
        disp (mess)
    end
    
end

% Cleanup
% -------
% Clean the function evaluation routine of buffered results to save memory
multifit_lsqr_func_eval


%------------------------------------------------------------------------------------------
function jac=multifit_dfdpf(w,xye,func,bkdfunc,pin,bpin,p,pinfo,f,dp,listing)
% Calculate partial derivatives of function with respect to parameters
%
%   >> jac=multifit_dfdpf(w,xye,func,bkdfunc,pin,bpin,p,pinfo,f,dp)
%
%   w       Cell array of data objects
%   xye     Logical array sye(i)==true if w{i} is x-y-e triple
%   func    Handle to global function
%   bkdfunc Cell array of handles to background functions
%   pin     Function arguments for global function
%   bpin    Cell array of function arguments for background functions
%   p       Parameter values of free parameters
%   pinfo   Structure with information to convert free parameters to numerical
%           parameters needed for function evaluation
%   f       Function values at parameter values p sbove
%   dp      Fractional step change in p for calculation of partial derivatives
%                - if dp > 0    calculate as (f(p+h)-f(p))/h
%                - if dp < 0    calculate as (f(p+h)-f(p-h))/(2h)
%   listing Screen output control
%
%   jac     Matrix of partial derivatives: m x n array where m=length(f) and
%           n = length(p)
%

if listing>2, disp(' Calculating partial derivatives:'), end

jac=zeros(length(f),length(p)); % initialise Jacobian to zero
min_abs_del=1e-12;
for j=1:length(p)
    if listing>2, disp(['    Parameter ',num2str(j),':']), end
    del=dp*p(j);                % dp is fractional change in parameter
    if abs(del)<=min_abs_del    % Ensure del non-zero
        if p(j)>=0
            del=min_abs_del;
        else
            del=-min_abs_del;
        end
    end
    if dp>=0
        ppos=p; ppos(j)=p(j)+del;
        jac(:,j)=(multifit_lsqr_func_eval(w,xye,func,bkdfunc,pin,bpin,ppos,pinfo,false,listing)-f)/del;
    else
        ppos=p; ppos(j)=p(j)+del;
        pneg=p; pneg(j)=p(j)-del;
        jac(:,j)=(multifit_lsqr_func_eval(w,xye,func,bkdfunc,pin,bpin,ppos,pinfo,false,listing) -...
                  multifit_lsqr_func_eval(w,xye,func,bkdfunc,pin,bpin,pneg,pinfo,false,listing))/(2*del);
    end
end

%------------------------------------------------------------------------------------------
% Functions for listing to screen (separated to keep main code tidy)

function fit_listing_header(listing,niter)
if listing==1
    disp('--------------------------------------')
    disp(sprintf('Beginning fit (max %d iterations)',niter));
    disp('--------------------------------------')
    disp('Iteration  Time(s)  Reduced Chi^2');
else
    disp('--------------------------------------------------------------------------------')
    disp(sprintf('Beginning fit (max %d iterations)',niter));
end
tic

%-------------------------------
function fit_listing_iteration_header(listing,iter)
if listing>1
    disp('--------------------------------------------------------------------------------')
    disp(['Iteration = ',num2str(iter)])
    disp('------------------')
end

%-------------------------------
function fit_listing_iteration(listing,iter,chisqr_red,lambda,pvary)
if listing==1
    disp(sprintf('   %3d      %8.3f   %9.4f', iter, toc, chisqr_red));
else
    disp([' Total time = ',num2str(toc),'s    Reduced Chi^2 = ',num2str(chisqr_red),...
        '      Levenberg-Marquardt = ', num2str(lambda)])
    disp(' Free parameter values:')
    np=numel(pvary);
    for irow=1:ceil(np/5)
        disp(sprintf('%14.4g %14.4g %14.4g %14.4g %14.4g',pvary(5*irow-4:min(5*irow,np))))
    end
    disp(' ')
end

%-------------------------------
function fit_listing_final(listing, p_best, sig, cor, pinfo)
if listing==1
    disp('Fit converged')
else
    [p,bp]=ptrans_par(p_best,pinfo);
    [psig,bsig]=ptrans_sigma(sig,pinfo);
    disp('--------------------------------------------------------------------------------')
    disp('Fit converged:')
    disp(' ')
    disp('Parameter values (free parameters with error estimates):')
    disp('--------------------------------------------------------')
    if pinfo.nptot>0       % there is at least one foreground function with one or more parameters
        disp(' ')
        disp('Foreground parameter values:')
        disp('----------------------------')
        fit_listing_final_parameters(p,psig,true,pinfo.fore,pinfo.bkgd,pinfo.np,pinfo.nbp)
    end
    if pinfo.nbptot>0       % there is at least one foreground function with one or more parameters
        disp(' ')
        disp('Background parameter values:')
        disp('----------------------------')
        fit_listing_final_parameters(bp,bsig,false,pinfo.bkgd,pinfo.fore,pinfo.np,pinfo.nbp)
    end
    disp(' ')
    disp('Covariance matrix for free parameters:')
    disp('--------------------------------------')
    disp(cor);
end

%-------------------------------
function fit_listing_final_parameters(p,sig,foreparams,this,that,np,nbp)
nptot=numel(np);
nbptot=numel(nbp);
for i=1:numel(p)
    if numel(p)>1
        disp(['  Function ',arraystr(size(p),i),':'])
    end
    for ip=1:numel(p{i})
        value=p{i}(ip);
        sigma=sig{i}(ip);
        if this.pfree{i}(ip)
            % Free parameter
            disp(sprintf('%5d %14.4g %s %-14.4g', ip, value,'  +/-  ', sigma))
            
        elseif this.pbound{i}(ip)
            % Bound parameter
            pboundto=this.ipboundto{i}(ip);             % index of parameter to which bound
            fboundto=abs(this.ifuncboundto{i}(ip));     % index of function to which bound
            forebound=(this.ifuncboundto{i}(ip)<0);     % true if bound to foreground function
            sametypebound=(foreparams==forebound);      % true if bound within same type of function
            if sametypebound
                floating=this.pfree{fboundto}(pboundto);% true if floating parameter
            else
                floating=that.pfree{fboundto}(pboundto);% true if floating parameter
            end
            if fboundto==i && sametypebound
                % Bound to a parameter within the same function
                if floating
                    disp(sprintf('%5d %14.4g %s %-14.4g %s', ip, value,'  +/-  ', sigma,...
                        ['    bound to parameter ',num2str(pboundto)]))
                else
                    disp(sprintf('%5d %14.4g %s %s', ip, value, '                      ',...
                        ['    bound to parameter ',num2str(pboundto)]))
                end
                
            elseif fboundto==1 && ((forebound && nptot==1) || (~forebound && nbptot==1))
                % Bound to a parameter of a global function (but not itself)
                if forebound
                    functype_str='foreground';
                else
                    functype_str='background';
                end
                if floating
                    disp(sprintf('%5d %14.4g %s %-14.4g %s', ip, value,'  +/-  ',sigma,...
                        ['    bound to parameter ',num2str(pboundto),' of ',functype_str,' function']))
                else
                    disp(sprintf('%5d %14.4g %s %s', ip, value, '                      ',...
                        ['    bound to parameter ',num2str(pboundto),' of ',functype_str,' function']))
                end
                
            else
                % Bound to a parameter of a local function (but not itself)
                if forebound
                    functype_str='foreground';
                    funcind_str =arraystr(size(np),fboundto);
                else
                    functype_str='background';
                    funcind_str =arraystr(size(nbp),fboundto);
                end
                if floating
                    disp(sprintf('%5d %14.4g %s %-14.4g %s',ip, value,'  +/-  ',sigma,...
                        ['    bound to parameter ',num2str(pboundto),' of ',functype_str,' ',funcind_str]))
                else
                    disp(sprintf('%5d %14.4g %s %s',ip, value, '                      ',...
                        ['    bound to parameter ',num2str(pboundto),' of ',functype_str,' ',funcind_str]))
                end
                
            end
        else
            % Fixed parameter
            disp(sprintf('%5d %14.4g',ip,value))
        end
    end
    disp(' ')
end
