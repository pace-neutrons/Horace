function ind = parposfun2ind (ip, ifun, np, nbp)
% Get the linear index of parameters from their parameter and function index
% This version is for all positive function index representation
%
%   >> ind = parposfun2ind (ip, ifun, np, nbp)
%
% Input:
% ------
%   ip      Parameter index within the function (column vector)
%   ifun    Function index in all positive representation (column vector):
%               foreground functions: numbered 1,2,3,...numel(np)
%               background functions: numbered numel(np)+(1,2,3,...numel(nbp))
%   np      Number of parameters in each of the foreground functions (row vector)
%   nbp     Number of parameters in each of the background functions (row vector)
%
% Output:
% -------
%   ind     Linear index of parameters in range (1:(sum(np)+sum(nbp)))' (column vector)
%
%
% Works for the case of ip and ifun, or np &/or nbp equal to [] i.e. totally general.


% Original author: T.G.Perring
%
% $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)


% Elementary check on size of parameters
if numel(ip)~=numel(ifun)
    error('Number of parameter and function indicies do not match')
end

% Get function indicies in all-positive representation
if any(ifun<1) || any(ifun>(numel(np)+numel(nbp)))
    error('Function index invalid')     % Check shouldn't be necessary
end

% Get parameter indicies
npp = [np, nbp]';
if any(ip<1) || any(ip>npp(ifun))
    error('Parameter index invalid')    % Check shouldn't be necessary
end

nppoff = [0;cumsum(npp)];
ind = ip + nppoff(ifun);
