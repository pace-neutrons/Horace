function [p_ok,sig_ok,perr,sigerr,converged]=test_NIST_datasetlist(S,namelist,p_tol,sig_tol)
% Test the datsets and fit functions in the NIST non-linear regression test suite
%
%   >> [wdata,wfit,fitpar]=test_NIST_dataset(S,name)
%   >> [wdata,wfit,fitpar]=test_NIST_dataset(S,name,'nodisp')
%
% Input:
% ------
%   S       Data structure containing the data
%   name    Cell array of name(s) of regresson test(s)
%           e.g. {'Misra1a', 'Chwirut2', 'Chwirut1', 'Lanczos3'}
% Optional:
%   p_tol   Acceptable relative tolerance on fit parameters
%   sig_tol Acceptable relative tolerance on 
%  'nodisp' Don't display fit information to the screen
%
%
% Output: (here n= number of dataset names in input argument 'name')
% -------
%   p_ok    Logical array size [n,3] with true for those test that
%           satisfied the parameter tolerance test (false if failed to
%           converge)
%   sig_ok  Logical array size [n,3] with true for those test that
%           satisfied the standard deviation tolerance test (false if
%           failed to converge)
%   perr    Array size [n,3] of the maximum relative error in the fitted
%           parameters, one element for each of the three initial starting
%           parameter sets
%   sigerr  Array size [n,3] with the same for the standard deviation estimates
% converged Logical array size [n,3] with true where fit converged, false otherwise


nf=numel(namelist);

perr=zeros(nf,3);
sigerr=zeros(nf,3);
converged=true(nf,3);
for i=1:nf
    disp(['=== Dataset: ',namelist{i},' ===']);
    [wdata,wfit,fitpar,perr(i,:),sigerr(i,:)]=test_NIST_dataset(S,lower(namelist{i}),'nodisp');
    converged(i,1)=fitpar(1).converged;
    converged(i,2)=fitpar(2).converged;
    converged(i,3)=fitpar(3).converged;
end

if nargin<3, p_tol=Inf; end
if nargin<4, sig_tol=Inf; end
p_ok=(perr<=p_tol) & converged;
sig_ok=(sigerr<=sig_tol) & converged;

% Display summary
str=repmat(' ',1,80);
cstr=repmat({str},nf,1);
p_ind=[12,15,18];
sig_ind=[25,28,31];
headstr='Name       b0 b1 breal  s0 s1 sreal';
for i=1:nf
    nch=numel(namelist{i});
    cstr{i}(1:nch)=namelist{i};
    cstr{i}(p_ind(~p_ok(i,:)))='x';
    cstr{i}(sig_ind(~sig_ok(i,:)))='x';
end

disp(' ')
disp('--------------------------------------');
disp(headstr)
disp('--------------------------------------');
disp(char(cstr))
disp(' ')
disp(['Tolerance: pars = ',num2str(p_tol),';  st.devs = ',num2str(sig_tol)])
disp(' ')
