function [p_best,sig,cor,chisqr_red,f_best]=fit_lsqr(x,yval,err,pin,pfree,func,listing,fcp)
%
%  >> [p, sig]=fit_lsqr(x,yval,err,pin,pfree,func,fcp)
%
% Input:
% ======
%   x       A cell array of length n, where x{i} gives the coordinates in the
%           ith dimension for all the data points. The arrays can have any
%           size, but they must all have the same size.
%
%   yval    Array containing the data values. Has the same size as any one of the x{i}
%
%   e       Array containng the corresponding error bars
%
%   func    Function handle to function to be fitted e.g. @gauss
%           Must have form:
%               y = my_function (x1,x2,... ,xn,p,c1,c2,...)
%
%            or, more generally:
%               y = my_function (x1,x2,... ,xn,p)
%
%               - p         a vector of numeric parameters that can be fitted
%               - c1,c2,... any further arguments needed by the function e.g.
%                          they could be the filenames of lookup tables for
%                          resolution effects)
%           e.g. Two dimensional Gaussian:
%               function y = gauss2d(x1,x2,p)
%               y = p(1).*exp(-0.5*(((x1 - p(2))/p(4)).^2+((x2 - p(3))/p(5)).^2);
%
%   pin     Initial function parameter values [pin(1), pin(2)...]
%            - If the function my_function takes just a numeric array of parameters, p, then this
%             contains the initial values [pin(1), pin(2)...]
%            - If further parameters are needed by my_function, then wrap as a cell array
%               {[pin(1), pin(2)...], c1, c2, ...}
%
%   pfree   Indicates which are the free parameters in the fit
%           e.g. [1,0,1,0,0] indicates first and third are free
%           Default: all are free
%
%   listing Numeric code to control output to Matlab command window to monitor
%           status of fit
%               =0 for no printing to command window
%               =1 prints iteration summary to command window
%               =2 additionally prints parameter values at each iteration
%
%   fit     Array of fit control parameters
%           fcp(1)  relative step length for calculation of partial derivatives
%           fcp(2)  maximum number of iterations
%           fcp(3)  Stopping criterion: relative change in chi-squared
%                   i.e. stops if chisqr_new-chisqr_old < fcp(3)*chisqr_old


% T.G.Perring 11-Jan-2007:
% ------------------------
% Inspired by speclsqr.m from spec1d, but massively edited to make
% more memory efficient, remove redundant code, and especially rewrite the *AWFUL*
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

% Check input parameters
yval=yval(:); wt=1./err(:); pin{1}=pin{1}(:); pfree=pfree(:); % make column vectors

nval=length(yval);
np=length(pin{1});


if length(pin{1})~=length(pfree) || ~all(pfree==1|pfree==0)
    error ('Check argument pfree is all 0 or 1 and length of pin')
end
ipfree=find(pfree);     % index of parameters free to vary
npfree=length(ipfree);
if npfree>= nval
    error ('Number of data points must be greater than number of free parameters')
end

% listing to screen
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
f=func(x{:},pin{:}); 
resid=wt.*(yval-f);

p_best=pin;  % Best values for parameters at start
f_best=f;    % Function values at start
c_best=resid'*resid; % Un-normalised chi-squared

lambda_prev=1;
lambda_table=[.1 1 1e2 1e4 1e6];

% Iterate to find best solution
converged=0;
for iter=1:niter,
    p_prev=p_best;          % Store current best parameter values
    c_goal=(1-tol)*c_best;  % Goal for improvement in chisqr
    resid=wt.*(yval-f_best);
    jac=fit_dfdp(x,f_best,p_best,ipfree,dp,func);
    
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
    for itable=1:length(lambda_table)
        lambda = max(lambda_prev*lambda_table(itable),1e-7);
        se=sqrt((s.*s)+lambda);
        gse=g./se;
        p_chg=((v*gse).*nrm);   % compute change in parameter values
        if (any(abs(p_chg)>0))  % if any change in the parameters
            p=p_prev;
            p{1}(ipfree)=p{1}(ipfree)+p_chg;
            f=func(x{:},p{:});
            resid=wt.*(yval-f);
            c=resid'*resid;
%             % The following code appears logically better than the after this comment
%                   if c<=c_goal; p_best=p; f_best=f; c_best=c; break; end;
%             % because at present if chisqr improves, but not to better than c_goal, then
%             % p_best, f_best and c_best are updated. The hidden assumption 
%             % is that matrix v, g and nrm are nearly the same, so that it is not stupid,
%             % and that any improvement on p is worthwhile, no matter how arrived at.
            if c<c_best
                p_best=p;
                f_best=f;
                c_best=c;
                if c<=c_goal        % chisqr improved beyond goal, so move to main iteration loop
                    break;
                end
            end;
        end;
    end;
    lambda_prev = lambda;    % update Levenberg-Marquardt parameter
    
    % if chisqr lowered, but not to goal, so converged; or chisqr==0 i.e. perfect fit; then exit loop
    if (c_best>c_goal) || (c_best==0)
        converged=1;
        break;
    end
    
    % Output to command window
    if listing~=0
        fit_listing_iteration(listing, iter, c_best/(nval-npfree), lambda, p_best{1}(ipfree));
    end
end

% Wrap up for exit from fitting routine
if converged
    sig=zeros(np,1);
    chisqr_red = c_best/(nval-npfree);
    % Calculate covariance matrix
    jac=fit_dfdp(x,f_best,p_best,ipfree,dp,func);   
    for j=1:npfree
        jac(:,j)=wt.*jac(:,j);
    end;
    [jac,s,v]=svd(jac,0);
    s=repmat((1./diag(s))',[npfree,1]);
    v=v.*s;
    cov=chisqr_red*(v*v');  % true covariance matrix;
    sig(ipfree)=sqrt(diag(cov));
    tmp=repmat(1./sqrt(diag(cov)),[1,npfree]);
    cor=tmp.*cov.*tmp';
    if listing~=0, fit_listing_final(listing, p_best{1}, sig, ipfree, cor); end
else
    disp ('WARNING: Convergence not achieved')
    sig=[];
    chisqr_red = c_best/(nval-npfree);
    cor=[];
end

%------------------------------------------------------------------------------------------
function jac=fit_dfdp(x,f,p,ind,dp,func)
% Calculate partial derivatives of function with respect to parameters
%
%   >> jac=fit_dfdp(x,f,p,ind,dp,func)
%
%   x       x coordinates at which function is evaluated
%   f       Function values at parameter values p (below)
%   p       Parameter values that 
%   ind     List of parameter numbers that are free to vary
%   dp      Fractional step change in p for calculation of partial derivatives
%                - if dp > 0    calculate as (f(p+h)-f(p))/h
%                - if dp < 0    calculate as (f(p+h)-f(p-h))/h
%   func    Handle to function
%
%   jac     Matrix of partial derivatives: m x n array where m=length(f) and
%           n = length(p)
%

ppos=p;
if dp<0, pneg=p; end
jac=zeros(length(f),length(ind));     % initialise Jacobian to zero

for j=1:length(ind)
    jp=ind(j);
    del=dp*p{1}(jp);           % dp is fractional change in parameter
    if del==0, del=dp; end  % Ensure del non-zero 
    if dp>=0
        ppos{1}(jp)=p{1}(jp)+del;
        jac(:,j)=(func(x{:},ppos{:})-f)/del;
        ppos{1}(jp)=p{1}(jp);
    else
        ppos{1}(jp)=p{1}(jp)+del;
        pneg{1}(jp)=p{1}(jp)-del;
        jac(:,j)=(func(x{:},ppos{:})-func(x{:},pneg{:}))./(2*del);
        ppos{1}(jp)=p{1}(jp);
        pneg{1}(jp)=p{1}(jp);
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
function fit_listing_iteration(listing,iter,chisqr_red,lambda,pvary)
if listing==1
    disp(sprintf('   %3d      %8.3f   %9.4f', iter, toc, chisqr_red));
else
    disp('--------------------------------------------------------------------------------')
    disp(['Iteration = ',num2str(iter)])
    disp('------------------')
    disp([' total time = ',num2str(toc),'s    Reduced Chi^2 = ',num2str(chisqr_red),...
          '      Levenberg-Marquardt = ', num2str(lambda)])
    disp(' ')
    disp('Free parameter values:')
    np=numel(pvary);
    for irow=1:ceil(np/5)
        disp(sprintf('%14.4g %14.4g %14.4g %14.4g %14.4g',pvary(5*irow-4:min(5*irow,np))))
    end
    disp(' ')
end

%-------------------------------
function fit_listing_final(listing, p_best, sig, ipfree, cor)
if listing==1
    disp('Fit converged')
else
    disp('--------------------------------------------------------------------------------')
    disp('Fit converged:')
    disp(' ')
    disp('Parameter values (free parameters with error estimates):')
    is_free=zeros(size(p_best)); is_free(ipfree)=1;
    for ip=1:length(p_best)
        if is_free(ip)
            disp(sprintf('%14.4g %s %-14.4g',p_best(ip),'  +/-  ',sig(ip)))
        else
            disp(sprintf('%14.4g',p_best(ip)))
        end
    end
    disp(' ')
    disp('Covariance matrix for free parameters:')
    disp(cor);
end
