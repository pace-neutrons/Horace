function [test_fit_1,test_fit_1_1, test_fit_2,test_fit_3]=multifit_curve(w,xye,func,bfunc,pin,bpin,...
    f_pass_caller_info,bf_pass_caller_info,pfin,p_info,listing,fcp,perform_fit)
%
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
    yval{i}=yval{i}(:);         % make a column vector
    wt{i}=wt{i}(:);         % make a column vector
end
yval=cell2mat(yval(:));     % one long column vector
wt=cell2mat(wt(:));

% Check that there are more data points than free parameters
nval=numel(yval);
npfree=numel(pfin);
nnorm=max(nval-npfree,1);   % we allow for the case nval=npfree
if nval<npfree
    error("HERBERT:mfclass:multifit_lsqr",'Number of data points must be greater than or equal to the number of free parameters')
end

% Set the extent of listing to screen
if ~exist('listing', 'var') || isempty(listing)
    listing=0;
end

if ~exist('fcp', 'var')
    fcp=[0.0001, 20, 0.001];
end
dp=fcp(1);      % derivative step length
niter=fcp(2);   % maximum number of iterations
tol=fcp(3);     % convergence criterion
if abs(dp)<1e-12
    error("HERBERT:mfclass:multifit_lsqr",'Derivative step length must be greater or equal to 10^-12')
end
if niter<0
    error("HERBERT:mfclass:multifit_lsqr",'Number of iterations must be >=0')
end

y_data = yval;
e_data = wt;
init_params = pfin;

f_wrapper = @(pfin,store_calc)double(multifit_f(w,xye,func,bfunc,pin,bpin,f_pass_caller_info,...
                          bf_pass_caller_info,pfin,p_info,false,[],[],listing));

% f_wrapper = @(w,pfin)(func{1}(w{iw},pars{:}));
r_wrapper = @(pfin, x)double(multifit_residuals_2(wt,yval,f_wrapper(pfin,false)));

j_wrapper = @(pfin, x)double(multifit_dfdpf(wt,w,xye,func,bfunc,pin,bpin,...
    f_pass_caller_info,bf_pass_caller_info,pfin,p_info,f_wrapper(pfin,false),dp,[],[],listing));

c_wrapper = @(pfin, x)double(multifit_cost(r_wrapper(pfin,[])));

options = optimoptions("lsqcurvefit", "Algorithm", "levenberg-marquardt",...
                       "SpecifyObjectiveGradient", true);
%                        "MaxIterations", 10000,"FunctionTolerance", 1.0000e-10,...
%                        "StepTolerance", 1e-10,"MaxFunctionEvaluations" ,30000,....

options2 = optimoptions("lsqcurvefit", "Algorithm", "levenberg-marquardt");
%                       "SpecifyObjectiveGradient", true);
%                        "MaxIterations", 10000,"FunctionTolerance", 1.0000e-10,...
%                        "StepTolerance", 1e-10,"MaxFunctionEvaluations" ,30000,....
                       
jr_wrapper = @(pfin,x)(multifit_resid_dfdpf(wt,w,xye,func,bfunc,pin,bpin,...
    f_pass_caller_info,bf_pass_caller_info,pfin,p_info,f_wrapper(pfin,false),dp,[],[],listing,yval));

x = zeros(length(yval),1);
amp = 6000;
fwhh = 0.2;
pars = double([amp fwhh]);
[results1,rnorm,r,flags,output] = lsqcurvefit(jr_wrapper,pfin,[],yval,[],[],options);
r
plot(r)
output
%test_fit_1 ="";
test_fit_1 = results1 ;

[results_1_1,~,~,flags_1_1,~] = lsqcurvefit(f_wrapper,pfin,[],yval,[],[],options2);
%test_fit_1_1 ="";
test_fit_1_1 = results_1_1;




results2 = nlinfit(x,x,r_wrapper,pfin);

%results2 = "";
test_fit_2 = results2 ;



%opt_fim =  optimset("MaxFunEvals",1e100);
results3 = fminsearch(c_wrapper,pfin);
%results3 = "";
test_fit_3 = results3;



end

