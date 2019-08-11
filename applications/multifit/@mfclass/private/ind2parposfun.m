function [ip, ifun] = ind2parposfun (ind, np, nbp)
% Get parameter and function index from the linear parameter index
% This version is for all positive function index representation
%
%   >> [ip, ifun] = ind2parposfun (ind, np, nbp)
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
%   ifun    Function index in all positive representation (column vector):
%               foreground functions: numbered 1,2,3,...numel(np)
%               background functions: numbered numel(np)+(1,2,3,...numel(nbp))
%
%
% Works for the case of ip and ifun, or np &/or nbp equal to [] i.e. totally general.


% Original author: T.G.Perring
%
% $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)


% Elementary check on size of parameters
npptot = sum(np) + sum(nbp);
if any(ind<0) || any(ind>npptot)
    error('Parameter index invalid')    % Check shouldn't be necessary
end

% Create lookup tables
iplook = sawtooth_iarray ([np,nbp]);
ifunlook = replicate_iarray(1:(numel(np)+numel(nbp)), [np,nbp]);

% Get parameter indicies
ip = iplook(ind);
ifun = ifunlook(ind);
