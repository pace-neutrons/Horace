function [p_best,sig,cor,chisqr_red]=multifit_lsqr(w,xye,func,bkdfunc,pin,bpin,pfin,pinfo,listing,fcp)

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
    yval{i}=yval{i}(:);       % make a column vector
    wt{i}=wt{i}(:);   % make a column vector
end
yval=cell2mat(yval(:));    % one long column vector
wt=cell2mat(wt(:));

% Check that there are more data points than free parameters
nval=numel(yval);
npfree=numel(pfin);
if ~(npfree< nval)
    error ('Number of data points must be greater than number of free parameters')
end

% Listing to screen
if ~exist('listing','var'), listing=0; end
if isempty(listing), listing=0; end
    
% Set fit control parameters
if ~exist('fcp','var')
    fcp=[0.0001 20 0.001];
end
dp=fcp(1);      % derivative step length
niter=fcp(2);   % maximum number of iterations
tol=fcp(3);     % convergence criterion
if niter<0
    error ('Number of iterations must be >=0')
end
if tol<0
    error ('Tolerance (fraction of chi-squared) must be >=0')
end

% Output to command window
if listing~=0, fit_listing_header(listing,niter); end

% Starting values of parameters and function values
f=multifit_lsqr_func_eval(w,xye,func,bkdfunc,pin,bpin,pfin,pinfo);
resid=wt.*(yval-f);

p_best=pfin; % Best values for parameters at start
f_best=f;    % Function values at start
c_best=resid'*resid; % Un-normalised chi-squared

lambda=1;
lambda_table=[1e1 1e1 1e2 1e2 1e2 1e2];

% Iterate to find best solution
converged=0;
max_rescale_lambda=0;
for iter=1:niter
    if listing~=0, fit_listing_iteration_header(listing,iter); end
    % Single value decomposition of 
    resid=wt.*(yval-f_best);
    jac=multifit_dfdpf(w,xye,func,bkdfunc,pin,bpin,p_best,pinfo,f_best,dp);
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
    c_goal=(1-tol)*c_best;  % Goal for improvement in chisqr
    lambda=lambda/10;
    for itable=1:numel(lambda_table)
        se=sqrt((s.*s)+lambda);
        gse=g./se;
        p_chg=((v*gse).*nrm);   % compute change in parameter values
        if (any(abs(p_chg)>0))  % if any change in the parameters
            p=p_best+p_chg;
            f=multifit_lsqr_func_eval(w,xye,func,bkdfunc,pin,bpin,p,pinfo);
            resid=wt.*(yval-f);
            c=resid'*resid;
            if c<c_best
                p_best=p;
                f_best=f;
                c_best=c;
                break;
            end
        end;
        if itable==numel(lambda_table) % Gone to end of table without improving chisqr
            max_rescale_lambda=1;
            break;
        end
        if listing~=0, fit_listing_iteration(listing, iter, c/(nval-npfree), lambda, p); end
        % Chisqr didn't improve - increase lambda and recompute step in parameters
        lambda = lambda*lambda_table(itable);
    end

    % Output to command window
    if listing~=0, fit_listing_iteration(listing, iter, c_best/(nval-npfree), lambda, p_best); end
    
    % if chisqr lowered, but not to goal, so converged; or chisqr==0 i.e. perfect fit; then exit loop
    if (c_best>c_goal) || (c_best==0)
        converged=1;
        break;
    end
    
    % If multipled lambda to limit of the table, give up
    if  max_rescale_lambda==1
        converged=0;
        break
    end
    
end

% Wrap up for exit from fitting routine
if converged
    chisqr_red = c_best/(nval-npfree);
    % Calculate covariance matrix
    jac=multifit_dfdpf(w,xye,func,bkdfunc,pin,bpin,p_best,pinfo,f_best,dp);
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
    disp ('WARNING: Convergence not achieved')
    sig=[];
    chisqr_red = c_best/(nval-npfree);
    cor=[];
end

% Clean the function evaluation routine of buffered results to save memory
multifit_lsqr_func_eval


%------------------------------------------------------------------------------------------
function jac=multifit_dfdpf(w,xye,func,bkdfunc,pin,bpin,p,pinfo,f,dp)
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
%
%   jac     Matrix of partial derivatives: m x n array where m=length(f) and
%           n = length(p)
%

jac=zeros(length(f),length(p));     % initialise Jacobian to zero

for j=1:length(p)
    del=dp*p(j);            % dp is fractional change in parameter
    if del==0, del=dp; end  % Ensure del non-zero 
    if dp>=0
        ppos=p; ppos(j)=p(j)+del;
        jac(:,j)=(multifit_lsqr_func_eval(w,xye,func,bkdfunc,pin,bpin,ppos,pinfo)-f)/del;
    else
        ppos=p; ppos(j)=p(j)+del;
        pneg=p; pneg(j)=p(j)-del;
        jac(:,j)=(multifit_lsqr_func_eval(w,xye,func,bkdfunc,pin,bpin,ppos,pinfo) -...
                  multifit_lsqr_func_eval(w,xye,func,bkdfunc,pin,bpin,pneg,pinfo))/(2*del);
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
    [p,bp]=ptrans(p_best,pinfo);
    [psig,bsig]=ptrans_sig(sig,pinfo);
    disp('--------------------------------------------------------------------------------')
    disp('Fit converged:')
    disp(' ')
    disp('Parameter values (free parameters with error estimates):')
    disp('--------------------------------------------------------')
    for ip=1:numel(p)
        if pinfo.pfree(ip)
            disp(sprintf('%5d %14.4g %s %-14.4g',ip,p(ip),'  +/-  ',psig(ip)))
        elseif pinfo.pbound(ip)
            if pinfo.ipfunc(ip)==0
                if pinfo.pfree(pinfo.ipb(ip))
                    disp(sprintf('%5d %14.4g %s %-14.4g %s',ip,p(ip),'  +/-  ',psig(ip),...
                        ['    bound to parameter ',num2str(pinfo.ipb(ip))]))
                else
                    disp(sprintf('%5d %14.4g %s %s',ip,p(ip),'                      ',...
                        ['    bound to parameter ',num2str(pinfo.ipb(ip))]))
                end
            else
                if pinfo.bpfree{pinfo.ipfunc(ip)}(pinfo.ipb(ip))
                    disp(sprintf('%5d %14.4g %s %-14.4g %s',ip,p(ip),'  +/-  ',psig(ip),...
                        ['    bound to parameter ',num2str(pinfo.ipb(ip)),' of background ',arraystr(size(pinfo.nbp),pinfo.ipfunc(ip))]))
                else
                    disp(sprintf('%5d %14.4g %s %s',ip,p(ip),'                      ',...
                        ['    bound to parameter ',num2str(pinfo.ipb(ip)),' of background ',arraystr(size(pinfo.nbp),pinfo.ipfunc(ip))]))
                end
            end
        else
            disp(sprintf('%5d %14.4g',ip,p(ip)))
        end
    end
    

    if sum(pinfo.nbp(:))>0     % there is at least one background function with one or more parameters
        disp(' ')
        disp('Background parameter values:')
        disp('----------------------------')
        for i=1:numel(bp)
            for ip=1:numel(bp{i})
                if pinfo.bpfree{i}(ip)
                    disp(sprintf('%5d %14.4g %s %-14.4g',ip,bp{i}(ip),'  +/-  ',bsig{i}(ip)))
                elseif pinfo.bpbound{i}(ip)
                    if pinfo.ibpfunc{i}(ip)==0      % bound to a global parameter
                        if pinfo.pfree(pinfo.ibpb{i}(ip))
                            disp(sprintf('%5d %14.4g %s %-14.4g %s',ip,bp{i}(ip),'  +/-  ',bsig{i}(ip),...
                                ['    bound to parameter ',num2str(pinfo.ibpb{i}(ip)),' of global fit function']))
                        else
                            disp(sprintf('%5d %14.4g %s %s',ip,bp{i}(ip),'                      ',...
                                ['    bound to parameter ',num2str(pinfo.ibpb{i}(ip)),' of global fit function']))
                        end
                    elseif pinfo.ibpfunc{i}(ip)==i  % bound to a parameter within the same background function
                        if pinfo.bpfree{i}(pinfo.ibpb{i}(ip))
                            disp(sprintf('%5d %14.4g %s %-14.4g %s',ip,bp{i}(ip),'  +/-  ',bsig{i}(ip),...
                                ['    bound to parameter ',num2str(pinfo.ibpb{i}(ip))]))
                        else
                            disp(sprintf('%5d %14.4g %s %-14.4g %s',ip,bp{i}(ip),'                      ',...
                                ['    bound to parameter ',num2str(pinfo.ibpb{i}(ip))]))
                        end
                    else                            % bound to another background function
                        if pinfo.bpfree{pinfo.ibpfunc{i}(ip)}(pinfo.ibpb{i}(ip))
                            disp(sprintf('%5d %14.4g %s %-14.4g %s',ip,bp{i}(ip),'  +/-  ',bsig{i}(ip),...
                                ['    bound to parameter ',num2str(pinfo.ibpb{i}(ip)),' of background ',arraystr(size(pinfo.nbp),pinfo.ibpfunc{i}(ip))]))
                        else
                            disp(sprintf('%5d %14.4g %s %-14.4g %s',ip,bp{i}(ip),'  +/-  ',bsig{i}(ip),...
                                ['    bound to parameter ',num2str(pinfo.ibpb{i}(ip)),' of background ',arraystr(size(pinfo.nbp),pinfo.ibpfunc{i}(ip))]))

                        end
                    end
                else
                    disp(sprintf('%5d %14.4g',ip,bp{i}(ip)))
                end
            end
            disp(' ')
        end
    end
    disp(' ')
    disp('Covariance matrix for free parameters:')
    disp('--------------------------------------')
    disp(cor);
end
