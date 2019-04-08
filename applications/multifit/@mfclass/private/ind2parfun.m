function [ip, ifun] = ind2parfun (ind, np, nbp)
% Get parameter and function index from the linear parameter index
%
%   >> [ip, ifun] = ind2parfun (ind, np, nbp)
%
% Input:
% ------
%   ind     Linear index of parameters in range (1:(sum(np)+sum(nbp)))' (column vector)
%   np      Number of parameters in each of the foreground functions (row vector)
%   nbp     Number of parameters in each of the background functions (row vector)
%
% Output:
% -------
%   ip      Parameter index within the function (column vector)
%   ifun    Function index (column vector):
%               foreground functions: numbered 1,2,3,...numel(np)
%               background functions: numbered -1,-2,-3,...-numel(nbp)
%
%
% Works for the case of ip and ifun, or np &/or nbp equal to [] i.e. totally general.


% Original author: T.G.Perring
%
% $Revision:: 830 ($Date:: 2019-04-08 16:16:02 +0100 (Mon, 8 Apr 2019) $)


% Elementary check on size of parameters
npptot = sum(np) + sum(nbp);
if any(ind<0) || any(ind>npptot)
    error('Parameter index invalid')    % Check shouldn't be necessary
end

% Create lookup tables
iplook = sawtooth_iarray ([np,nbp]);
ifunlook = replicate_iarray([1:numel(np),-1:-1:-numel(nbp)], [np,nbp]);

% Get parameter indicies
ip = iplook(ind);
ifun = ifunlook(ind);
