function [wdata,wfit,fitpar,perr,sigerr]=test_NIST_dataset(S,name,opt)
% Test one of the datsets and fit functions in the NIST non-linear regression test suite
%
%   >> [wdata,wfit,fitpar]=test_NIST_dataset(S,name)
%   >> [wdata,wfit,fitpar]=test_NIST_dataset(S,name,'nodisp')
%
% Input:
% ------
%   S       Data structure containing the data
%   name    Name of regresson test e.g. 'gauss2'
%  'nodisp' Don't display fit information to the screen
%
%
% Output:
% -------
%   wdata   IX_dataset_1d dataset with the data fot he test
%   wfit    Array length 3 of the results of the fits starting from
%           (1) Initial parameter set b0 (far from the solution)
%           (2) Initial parameter set b1 (near the solution)
%           (3) Initial parameter set breal (the actual solution)
%   fip     Array of multifit parameter fit structures, one for each
%           of the three fits
%   perr    Vector length 3 of the maximum relative error in the fitted
%           parameters, one element for each of the three initial starting
%           parameter sets
%   sigerr  Vector length 3 with the same for the standard deviation estimates


% Get display option
if nargin==3
    if ischar(opt) && strcmpi(opt,'nodisp')
        nodisp=true;
    else
        error('Invalid option')
    end
else
    nodisp=false;
end

% Extract model
if isfield(S,name)
    d=S.(name);
    if ~isfield(d,'x')
        error('Invalid test function')
    end
else
    error(['Test function: ''',name,''' does not exist'])
end

% Get data
x=d.x;
if size(x,2)~=1
    error(['Data set: ''',name,''' has more than one predictor variable; test cannot be performed'])
end
y=d.y;
[x,ix]=sort(x);     % sort, as not all data points are in increasing order
y=y(ix);
e=ones(size(d.x));
wdata=IX_dataset_1d(x,y,e,['Model name: ',name],'','');

% Perform fit
func=d.f;

if ~nodisp
    disp('================================================================================')
    disp('Starting parameter set b0:')
    disp('--------------------------')
end
pinit=d.b0;
[yfit,fitp]=multifit(x,y,e,@nistfunc_eval,{pinit,func});
[perr(1),sigerr(1)]=display_fit(d,fitp,nodisp);
wfit=IX_dataset_1d(x,yfit,zeros(size(x)),['Model name: ',name,' - b0'],'','');
fitpar=fitp;
if ~nodisp
    disp(' ')
    disp(' ')
end

if ~nodisp
    disp('================================================================================')
    disp('Starting parameter set b1:')
    disp('--------------------------')
end
pinit=d.b1;
[yfit,fitp]=multifit(x,y,e,@nistfunc_eval,{pinit,func});
[perr(2),sigerr(2)]=display_fit(d,fitp,nodisp);
wfit(2)=IX_dataset_1d(x,yfit,zeros(size(x)),['Model name: ',name,' - b0'],'','');
fitpar(2)=fitp;
if ~nodisp
    disp(' ')
    disp(' ')
end

if ~nodisp
    disp('================================================================================')
    disp('Starting parameter set breal:')
    disp('-----------------------------')
end
pinit=d.breal;
[yfit,fitp]=multifit(x,y,e,@nistfunc_eval,{pinit,func});
[perr(3),sigerr(3)]=display_fit(d,fitp,nodisp);
wfit(3)=IX_dataset_1d(x,yfit,zeros(size(x)),['Model name: ',name,' - b0'],'','');
fitpar(3)=fitp;
if ~nodisp
    disp(' ')
end


%--------------------------------------------------------------------
function y=nistfunc_eval(x,p,func)
% Evaluate the nist function handle, func
y=func(p,x);


%--------------------------------------------------------------------
function [perr,sigerr]=display_fit(d,fitpar,nodisp)
% Display error in the fit compared to certified values
prelerr=abs((d.breal(:)-fitpar.p(:))./d.breal(:));
sigrelerr=abs((d.bsd(:)-fitpar.sig(:))./d.bsd(:));
perr=max(prelerr);
sigerr=max(sigrelerr);
arr=[d.breal(:),fitpar.p(:),prelerr,d.bsd(:),fitpar.sig(:),sigrelerr];
if ~nodisp
    disp('   pref          pfit         relerr        sigref        sigfit     relerr')
    disp('--------------------------------------------------------------------------------')
    disp(num2str(arr))
    disp(' ')
    disp(['Max relerr on parameter fit: ',num2str(perr)])
    disp(['     Max relerr on st. dev.: ',num2str(sigerr)])
end
