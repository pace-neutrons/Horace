function [psig,bsig]=ptrans_sigma(sigfree,p_info)
% Transform free parameter errors into array matching the sizes of the parameters
%
%   >> [psig,bsig]=ptrans_sigma(sig_free,p_info)
%
% Input:
% ------
%   sigfree Array of standard deviations of free parameters
%   p_info  Structure containing information to convert to function parameters
%          (See the function ptrans_initialise for details)
%
% Output:
% -------
%   psig    Column cell array of column vectors, each with the standard deviations
%          on the parameter values for the foreground function(s)
%   bsig    Column cell array of column vectors, each with the standard deviations
%          on the parameter values for the background function(s)


% Original author: T.G.Perring
%
% $Revision:: 838 ($Date:: 2019-12-05 14:56:03 +0000 (Thu, 5 Dec 2019) $)


% Get list of estimated errors
sig=zeros(p_info.npptot,1);
sig(p_info.free)=sigfree;
sig(p_info.bound)=abs(p_info.ratio(p_info.bound)).*sig(p_info.ib(p_info.bound));     % ratio could be negative - must take absolute value

% Convert to cell arrays for foreground and background functions
if numel(p_info.np)==1
    psig={sig(1:p_info.nptot)};
else
    psig=vec_to_cell(sig(1:p_info.nptot),p_info.np);
end

if numel(p_info.nbp)==1
    bsig={sig(p_info.nptot+1:end)};
else
    bsig=vec_to_cell(sig(p_info.nptot+1:end),p_info.nbp(:));
end

