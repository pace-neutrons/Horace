function [psig,bsig]=ptrans_sigma(sigfree,w)
% Transform free parameter errors into array matching the sizes of the parameters
%
%   >> [psig,bsig]=ptrans_sigma(sig_free,w)
%
% Input:
% ------
%   sigfree Array of standard deviations of free parameters
%   w       Structure containing information to convert to function parameters
%          (See the function ptrans_initialise for details)
%
% Output:
% -------
%   psig    Column cell array of column vectors, each with the standard deviations
%          on the parameter values for the foreground function(s)
%   bsig    Column cell array of column vectors, each with the standard deviations
%          on the parameter values for the background function(s)

% Get list of estimated errors
sig=zeros(w.npptot,1);
sig(w.free)=sigfree;
sig(w.bound)=abs(w.ratio(w.bound)).*sig(w.ib(w.bound));     % ratio could be negative - must take absolute value

% Convert to cell arrays for foreground and background functions
psig=mat2cell(sig(1:w.nptot),w.np(:),1);
bsig=mat2cell(sig(w.nptot+1:end),w.nbp(:),1);
