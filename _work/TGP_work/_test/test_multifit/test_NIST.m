function test_NIST (p_tol, sig_tol)
% Interface to NIST test datasets for non-linear regression
% See: http://www.itl.nist.gov/div898/strd/nls/nls_main.shtml
%
%   >> test_NIST
%   >> test_NIST (p_tol, sig_tol)
%
% Input:
% ------
%   p_tol   Acceptable relative tolerance on fit parameters (Default: 1e-4)
%   sig_tol Acceptable relative tolerance on estimated standard deviations
%           (Default: 1e-2)
%
%
% The full set of tests is:
%
% Dataset   Level of    Model Class-    Number of   Number of   Source
% Name      Difficulty  ification       Parameters  Observations
% -----------------------------------------------------------------------------
%  
% Misra1a   Lower       Exponential     2           14          Observed 
% Chwirut2  Lower       Exponential     3           54          Observed 
% Chwirut1  Lower       Exponential     3           214         Observed 
% Lanczos3  Lower       Exponential     6           24          Generated 
% Gauss1    Lower       Exponential     8           250         Generated 
% Gauss2    Lower       Exponential     8           250         Generated 
% DanWood  	Lower       Miscellaneous   2           6           Observed 
% Misra1b   Lower       Miscellaneous   2           14          Observed 
% 
%  
% Kirby2    Average     Rational        5           151         Observed 
% Hahn1     Average     Rational        7           236         Observed 
% Nelson    Average     Exponential     3           128         Observed 
% MGH17     Average     Exponential     5           33          Generated 
% Lanczos1  Average     Exponential     6           24          Generated 
% Lanczos2  Average     Exponential     6           24          Generated 
% Gauss3    Average     Exponential     8           250         Generated  
% Misra1c   Average     Miscellaneous   2           14          Observed 
% Misra1d   Average     Miscellaneous   2           14          Observed 
% Roszman1  Average     Miscellaneous   4           25          Observed 
% ENSO      Average     Miscellaneous   9           168         Observed 
% 
%  
% MGH09     Higher      Rational        4           11          Generated 
% Thurber   Higher      Rational        7           37          Observed 
% BoxBOD    Higher      Exponential     2           6           Observed 
% Rat42     Higher      Exponential     3           9           Observed 
% MGH10     Higher      Exponential     3           16          Generated 
% Eckerle4  Higher      Exponential     3           35          Observed 
% Rat43     Higher      Exponential     4           15          Observed 
% Bennett5  Higher      Miscellaneous   3           154         Observed 


% Cell arrays with test names
% ---------------------------
% (Ignore 'Nelson' in the 'average' as a function of two x coords, and the
% test function test_NIST_dataset cannot cope with that)
f_lower={'Misra1a', 'Chwirut2', 'Chwirut1', 'Lanczos3',...
    'Gauss1', 'Gauss2', 'DanWood', 'Misra1b'};

 
f_average={'Kirby2', 'Hahn1', 'MGH17', 'Lanczos1', 'Lanczos2',...
    'Gauss3','Misra1c','Misra1d','Roszman1','ENSO'};

 
f_higher={'MGH09', 'Thurber', 'BoxBOD', 'Rat42', 'MGH10', 'Eckerle4',...
    'Rat43', 'Bennett5'};


% Read in data
% ------------
rootpath = fileparts(which(mfilename));
S=load(fullfile(rootpath,'nistdata.mat'));


% Perform tests
% -------------
if nargin==0
    p_tol=1e-4;
    sig_tol=1e-2;
elseif nargin~=2
    error('Check number of input arguments')
end

% Lower difficulty:
disp('======================================================================')
disp('  Lower difficulty level')
disp('======================================================================')
[p_ok,sig_ok,perr,sigerr,converged]=test_NIST_datasetlist(S,f_lower,p_tol,sig_tol);
disp(' ')
disp(' ')
disp(' ')

% Average difficulty:
disp('======================================================================')
disp('  Average difficulty level')
disp('======================================================================')
[p_ok,sig_ok,perr,sigerr,converged]=test_NIST_datasetlist(S,f_average,p_tol,sig_tol);
disp(' ')
disp(' ')
disp(' ')

% Higher difficulty:
disp('======================================================================')
disp('  Higher difficulty level')
disp('======================================================================')
[p_ok,sig_ok,perr,sigerr,converged]=test_NIST_datasetlist(S,f_higher,p_tol,sig_tol);
