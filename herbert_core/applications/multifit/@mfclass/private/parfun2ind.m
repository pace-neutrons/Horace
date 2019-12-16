function ind = parfun2ind (ip, ifun, np, nbp)
% Get the linear index of parameters from their parameter and function index
%
%   >> ind = parfun2ind (ip, ifun, np, nbp)
%
% Input:
% ------
%   ip      Parameter index within the function (column vector)
%   ifun    Function index (column vector):
%               foreground functions: numbered 1,2,3,...numel(np)
%               background functions: numbered -1,-2,-3,...-numel(nbp)
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
% $Revision:: 839 ($Date:: 2019-12-16 18:18:44 +0000 (Mon, 16 Dec 2019) $)


% Elementary check on size of parameters
if numel(ip)~=numel(ifun)
    error('Number of parameter and function indicies do not match')
end

% Get function indicies in all-positive representation
if any(ifun==0) || any(ifun<-numel(nbp)) || any(ifun>numel(np))
    error('Function index invalid')     % Check shouldn't be necessary
end
is_bp = (ifun<0);   % background function
ifun(is_bp) = numel(np) + abs(ifun(is_bp));

% Get parameter indicies
npp = [np, nbp]';
if any(ip<1) || any(ip>npp(ifun))
    error('Parameter index invalid')    % Check shouldn't be necessary
end

nppoff = [0;cumsum(npp)];
ind = ip + nppoff(ifun);

