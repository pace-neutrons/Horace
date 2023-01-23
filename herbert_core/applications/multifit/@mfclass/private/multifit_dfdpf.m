function jac = multifit_dfdpf(wt,w,xye,func,bfunc,pin,bpin,...
    f_pass_caller_info,bf_pass_caller_info,p,p_info,f,dp,S,Store,listing)
% Calculate partial derivatives of function with respect to parameters
%
%   >> jac=multifit_dfdpf(w,xye,func,bkdfunc,pin,bpin,...
%           f_pass_caller_info,bf_pass_caller_info,p,p_info,f,dp,S,Store,listing)
%
% Input:
% ------
%   w       Cell array of data objects
%   xye     Logical array sye(i)==true if w{i} is x-y-e triple
%   func    Handle to global function
%   bfunc   Cell array of handles to background functions
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
%   Store   Stored values of e.g. expensively evaluated lookup tables that
%           have been accumulated to during evaluation of the fit functions
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
% Similarly, any accumulating lookup tables are not stored, as these will be
% for changes to parameters in the calculation of partial derivatives, and
% so are not returned.





if listing>2
    disp(' Calculating partial derivatives:')
end

jac=zeros(length(f),length(p)); % initialise Jacobian to zero
min_abs_del=1e-12;
for j=1:length(p)
    if listing>2
        disp(['    Parameter ',num2str(j),':'])
    end
    del=dp*p(j);                % dp is fractional change in parameter
    if abs(del)<=min_abs_del    % Ensure del non-zero
        if p(j)>=0
            del=min_abs_del;
        else
            del=-min_abs_del;
        end
    end
    if dp>=0


        ppos=p;
        ppos(j)=p(j)+del;
        plus = multifit_lsqr_func_eval(w,xye,func,bfunc,pin,bpin,...
            f_pass_caller_info,bf_pass_caller_info,ppos,p_info,false,S,Store,listing);
        plus = cat(1, plus{:});
        jac(:, j) = (plus - f)/del;

    else
        ppos=p;
        ppos(j)=p(j)+del;
        pneg=p;
        pneg(j)=p(j)-del;
        plus = multifit_lsqr_func_eval(w,xye,func,bfunc,pin,bpin,...
            f_pass_caller_info,bf_pass_caller_info,ppos,p_info,false,S,Store,listing);
        minus = multifit_lsqr_func_eval(w,xye,func,bfunc,pin,bpin,...
            f_pass_caller_info,bf_pass_caller_info,pneg,p_info,false,S,Store,listing);
        plus = cat(1, plus{:});
        minus = cat(1, minus{:});
        jac(:, j) = (plus - minus)/(2*del);
    end
     
%    jac = jac.*wt;
    nrm=zeros(length(p),1);
    for k=1:length(p)
        jac(:,k)=wt.*jac(:,k);
        nrm(k)=jac(:,k)'*jac(:,k);
        if nrm(k)>0
            nrm(k)=1/sqrt(nrm(k));
        end
        jac(:,k)=nrm(k)*jac(:,k);
    end
%     [jac,s,v]=svd(jac,0);
             
end