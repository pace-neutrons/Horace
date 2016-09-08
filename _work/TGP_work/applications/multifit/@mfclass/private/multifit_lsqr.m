function [p_best,sig,cor,chisqr_red,converged,ok,mess]=multifit_lsqr(w,xye,func,bfunc,pin,bpin,...
    f_pass_caller_info,bf_pass_caller_info,pfin,p_info,listing,fcp,perform_fit)
% Perform least-squares minimisation
%
%   >> [p_best,sig,cor,chisqr_red,converged,ok,mess]=...
%       multifit_lsqr(w,xye,func,bkdfunc,pin,bpin,pfin,p_info,listing)
%
%   >> [p_best,sig,cor,chisqr_red,converged,ok,mess]=...
%       multifit_lsqr(w,xye,func,bkdfunc,pin,bpin,pfin,p_info,listing,fcp)
%
%   >> [p_best,sig,cor,chisqr_red,converged,ok,mess]=...
%       multifit_lsqr(w,xye,func,bkdfunc,pin,bpin,pfin,p_info,listing,fcp,perform_fit)
%
% Input:
% ------
%   w           Cell array where each element w(i) is either
%                 - an x-y-e triple with w(i).x a cell array of arrays, one
%                  for each x-coordinate,
%                 - a scalar object
%               All bad points will have been masked from an x-y-e triple
%               Objects will have their bad points internally masked too.
%
%
%   xye         Logical array, size(w): indicating which data are x-y-e
%              triples (true) or objects (false)
%
%   func        Handles to foreground functions:
%                 - A cell array with a single function handle (which will
%                  be applied to all the data sets);
%                 - Cell array of function handles, one per data set.
%               Some, but not all, elements of the cell array can be empty.
%              Empty elements are interpreted as not having a function to
%              evaluate for the corresponding data set.
%
%   bfunc       Handles to background functions; same format as func, above
%
%   pin         Cell array of valid parameter lists, one list per foreground function,
%              with the initial parameter values at the lowest level.
%
%   bin         Cell array of valid parameter lists, one list per background function,
%              with the initial parameter values at the lowest level.
%
%   f_pass_caller_info  Keep internal state of foreground function evaluation e.g. seed of random
%               number generator. Dictates the format of the fit fuction argument list.
%
%   bf_pass_caller_info Keep internal state of background function evaluation e.g. seed of random
%               number generator. Dictates the format of the fit fuction argument list.
%
%   pf          Free parameter initial values (that is, the independently 
%              varying parameters)
%
%   p_info      Structure with information needed to transform from pf to the
%              parameter values needed for function evaluation
%
%   listing     Control diagnostic output to the screen:
%               =0 for no printing to command window 
%               =1 prints iteration summary to command window 
%               =2 additionally prints parameter values at each iteration 
%               =3 additionally lists which datasets were computed for the
%                  foreground and background functions. Diagnostic tool.
%
%   fcp         Fit control parameters:
%           fcp(1)  Relative step length for calculation of partial derivatives 
%                   [Default: 1e-4] 
%           fcp(2)  Maximum number of iterations [Default: 20] 
%           fcp(3)  Stopping criterion: relative change in chi-squared 
%                   i.e. stops if (chisqr_new-chisqr_old) < fcp(3)*chisqr_old 
%                   [Default: 1e-3]
%
%   perform_fit Logical scalar = true if a fit is required, =false if
%              just need the value of chisqr. [Default: True]
%
%
% Output:
% -------
%   p_best      Column vector of final fit parameters - only for the 
%              independently varying parameters.
%
%   sig         Column vector of estimated standard deviations
%
%   cor         Correlation matrix for the free parameters
%
%   chisqr_red  Reduced chi-squared at final fit parameters
%
%   converged   True if fit converged; false if not.
%
%   ok          True: A fit could be performed. This includes the cases of
%                 both convergence and failure to converge
%               False: Fundamental problem with the input arguments e.g.
%                 the number of free parameters equals or exceeds the number
%                 of data points
%               
%   mess        Error message if ok==false; Empty string if ok==true.
%
% Note tat for the final fit parameters to be reliable, test that
% (ok && converged) is true.
%
%
% T.G.Perring Jan 2009:
% ------------------------
% Change calls to fit functions so that caller information is passed direcetly rather than
% via a function that stores persistent information. Makes cleanup easier and future
% refactoring onto multiple cores more straightforward.
%
% T.G.Perring Jan 2009:
% ------------------------
% Generalise to arbitrary data objects which have a certain set of methods defined on them (see
% notes elsewhere for details)
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


% -----------------------------------------------------------------------------------
% Initialisation
% -----------------------------------------------------------------------------------
% Initialise output parameters
p_best=pfin;
sig=zeros(1,numel(pfin));
cor=zeros(numel(pfin));
chisqr_red=0;
converged=false;
ok=true;
mess='';

% Package data values and weights (i.e. 1/error_bar) each into a single column vector
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

% Set the extent of listing to screen
if ~exist('listing','var') || isempty(listing)
    listing=0;
end


% -----------------------------------------------------------------------------------
% Perform fit (or evaulation of chisqr 
% -----------------------------------------------------------------------------------
if exist('perform_fit','var') && ~perform_fit
    % -----------------------------------------------------------------------------------
    % Case of solely evaluation of chi-squared at input set of parameters
    % -----------------------------------------------------------------------------------
    % This should always give the same result as niter=0. The only difference is that
    % if fitting with niter=0 then a warning message will be returned saying the fit
    % didn't converge
    
    if listing>2, disp(' Function evaluation:'), end
    f=multifit_lsqr_func_eval(w,xye,func,bfunc,pin,bpin,...
        f_pass_caller_info,bf_pass_caller_info,pfin,p_info,false,[],listing);
    resid=wt.*(yval-f);
    
    c_best=resid'*resid; % Un-normalised chi-squared
    chisqr_red = c_best/nnorm;
        
else
    % -----------------------------------------------------------------------------------
    % Case of parameter optimisation
    % -----------------------------------------------------------------------------------
    
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
    [f,~,S]=multifit_lsqr_func_eval(w,xye,func,bfunc,pin,bpin,...
        f_pass_caller_info,bf_pass_caller_info,pfin,p_info,true,[],listing);
    resid=wt.*(yval-f);
    
    p_best=pfin; % Best values for parameters at start
    f_best=f;    % Function values at start
    c_best=resid'*resid; % Un-normalised chi-squared

    if listing~=0, fit_listing_iteration_header(listing,0); end
    if listing~=0, fit_listing_iteration(listing, 0, c_best/nnorm, [], p_best); end

    lambda=1;
    lambda_table=[1e1 1e1 1e2 1e2 1e2 1e2];
    
    % Iterate to find best solution
    converged=false;
    max_rescale_lambda=false;
    for iter=1:niter
        if listing~=0, fit_listing_iteration_header(listing,iter); end
        
        % Compute Jacobian matrix
        resid=wt.*(yval-f_best);
        jac=multifit_dfdpf(w,xye,func,bfunc,pin,bpin,...
            f_pass_caller_info,bf_pass_caller_info,p_best,p_info,f_best,dp,S,listing);
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
        % If the change does not improve chisqr  then increase the
        % Levenberg-Marquardt parameter until it does (up to a maximum
        % number of times gicven by the length of lambda_table).
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
            if (any(abs(p_chg)>0))  % there is a change in (at least one of) the parameters
                p=p_best+p_chg;
                if listing>2, disp(' Function evaluation after stepping parmeters:'), end
                [f,~,S]=multifit_lsqr_func_eval(w,xye,func,bfunc,pin,bpin,...
                    f_pass_caller_info,bf_pass_caller_info,p,p_info,true,S,listing);
                resid=wt.*(yval-f);
                c=resid'*resid;
                if c<c_best || c==0
                    p_best=p;
                    f_best=f;
                    c_best=c;
                    break;
                end
                if listing~=0, fit_listing_iteration(listing, iter, c/nnorm, lambda, p); end
            end;
            if itable==numel(lambda_table) % Gone to end of table without improving chisqr
                max_rescale_lambda=true;
                break;
            end
            % Chisqr didn't improve - increase lambda and recompute step in parameters
            lambda = lambda*lambda_table(itable);
        end
        
        % Output to command window
        if listing~=0
            if ~max_rescale_lambda
                fit_listing_iteration(listing, iter, c_best/nnorm, lambda, p_best)
            else
                disp(' *** No improvement in chi-squared over previous iteration ***')
                fit_listing_iteration(listing, iter-1, c_best/nnorm, [], p_best)
            end
        end
        
        % If chisqr lowered, but not to goal, so converged; or chisqr==0 i.e. perfect fit; then exit loop
        if (c_best>c_goal) || (c_best==0)
            converged=true;
            break;
        end
        
        % If multipled lambda to limit of the table, give up
        if max_rescale_lambda
            converged=false;
            break
        end
        
    end
    
    % Wrap up for exit from fitting routine
    if converged
        chisqr_red = c_best/nnorm;
        % Calculate covariance matrix
        if listing>2, disp(' '), disp(' Fit converged; estimate errors and covariance matrix'), end
        % Recompute and store functions values at best parameters. (The stored values may not be
        % those for best parameters which will otherwise dramatically slow down the calculation
        % of the covariance matrix. If the stored values are for the best parameters, then this
        % is a low cost function call, so there is little penalty.)
        if listing>2, disp(' '), disp(' Function evaluation at best fit parameters:'), end
        [~,~,S]=multifit_lsqr_func_eval(w,xye,func,bfunc,pin,bpin,...
            f_pass_caller_info,bf_pass_caller_info,p_best,p_info,true,S,listing);
        % Now get Jacobian matrix
        jac=multifit_dfdpf(w,xye,func,bfunc,pin,bpin,...
            f_pass_caller_info,bf_pass_caller_info,p_best,p_info,f_best,dp,S,listing);
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
        if listing~=0, fit_listing_final(listing, p_best, sig, cor, p_info); end
    else
        chisqr_red = c_best/nnorm;
        ok=true;
        mess='WARNING: Convergence not achieved';
        disp (mess)
    end
    
end


%------------------------------------------------------------------------------------------
function jac=multifit_dfdpf(w,xye,func,bkdfunc,pin,bpin,...
    f_pass_caller_info,bf_pass_caller_info,p,p_info,f,dp,S,listing)
% Calculate partial derivatives of function with respect to parameters
%
%   >> jac=multifit_dfdpf(w,xye,func,bkdfunc,pin,bpin,...
%           f_pass_caller_info,bf_pass_caller_info,p,p_info,f,dp,S,listing)
%
% Input:
% ------
%   w       Cell array of data objects
%   xye     Logical array sye(i)==true if w{i} is x-y-e triple
%   func    Handle to global function
%   bkdfunc Cell array of handles to background functions
%   pin     Function arguments for global function
%   bpin    Cell array of function arguments for background functions
%   f_pass_caller_info  Keep internal state of foreground function evaluation
%   bf_pass_caller_info Keep internal state of background function evaluation
%   p       Parameter values of free parameters
%   p_info  Structure with information to convert free parameters to numerical
%           parameters needed for function evaluation
%   f       Function values at parameter values p sbove
%   dp      Fractional step change in p for calculation of partial derivatives
%                - if dp > 0    calculate as (f(p+h)-f(p))/h
%                - if dp < 0    calculate as (f(p+h)-f(p-h))/(2h)
%   S       Structure containing stored values and internal states of functions
%   listing Screen output control
%
% Output:
% -------
%   jac     Matrix of partial derivatives: m x n array where m=length(f) and
%           n = length(p)
%
%
% Note that the call to multifit_lsqr_func_eval in this function is only ever
% with store_calc==false. Consequently the stored value structure is never
% updated, so we do not need to pass it back from this function.

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
        jac(:,j)=(multifit_lsqr_func_eval(w,xye,func,bkdfunc,pin,bpin,...
            f_pass_caller_info,bf_pass_caller_info,ppos,p_info,false,S,listing)-f)/del;
    else
        ppos=p; ppos(j)=p(j)+del;
        pneg=p; pneg(j)=p(j)-del;
        jac(:,j)=(multifit_lsqr_func_eval(w,xye,func,bkdfunc,pin,bpin,...
            f_pass_caller_info,bf_pass_caller_info,ppos,p_info,false,S,listing) -...
                  multifit_lsqr_func_eval(w,xye,func,bkdfunc,pin,bpin,...
                  f_pass_caller_info,bf_pass_caller_info,pneg,p_info,false,S,listing))/(2*del);
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
    if iter>0
        disp(['Iteration = ',num2str(iter)])
        disp('------------------')
    else
        disp( 'Starting point')
        disp('------------------')
    end
end

%-------------------------------
function fit_listing_iteration(listing,iter,chisqr_red,lambda,pvary)
if listing==1
    disp(sprintf('   %3d      %8.3f   %9.4f', iter, toc, chisqr_red));
else
    if ~isempty(lambda)
        disp([' Total time = ',num2str(toc),'s    Reduced Chi^2 = ',num2str(chisqr_red),...
            '      Levenberg-Marquardt = ', num2str(lambda)])
    else
        disp([' Total time = ',num2str(toc),'s    Reduced Chi^2 = ',num2str(chisqr_red)])
    end
    disp(' Free parameter values:')
    np=numel(pvary);
    for irow=1:ceil(np/5)
        disp(sprintf('%14.4g %14.4g %14.4g %14.4g %14.4g',pvary(5*irow-4:min(5*irow,np))))
    end
    disp(' ')
end

%-------------------------------
function fit_listing_final(listing, p_best, sig, cor, p_info)
if listing==1
    disp('Fit converged')
else
    [p,bp]=ptrans_par(p_best,p_info);
    [psig,bsig]=ptrans_sigma(sig,p_info);
    disp('--------------------------------------------------------------------------------')
    disp('Fit converged:')
    disp(' ')
    disp('Parameter values (free parameters with error estimates):')
    disp('--------------------------------------------------------')
    if p_info.nptot>0       % there is at least one foreground function with one or more parameters
        disp(' ')
        disp('Foreground parameter values:')
        disp('----------------------------')
        fit_listing_final_parameters(p,psig,true,p_info.fore,p_info.bkgd,p_info.np,p_info.nbp)
    end
    if p_info.nbptot>0       % there is at least one foreground function with one or more parameters
        disp(' ')
        disp('Background parameter values:')
        disp('----------------------------')
        fit_listing_final_parameters(bp,bsig,false,p_info.bkgd,p_info.fore,p_info.np,p_info.nbp)
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
