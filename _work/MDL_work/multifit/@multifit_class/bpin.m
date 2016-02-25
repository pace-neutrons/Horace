function [par,np] = bpin(obj, in_par)
% Field containing the initial parameters for the background fit function(s)
%
% Valid inputs are:
%   - For 'global_background':
%      - An array of parameters 
%      - A cell array whose first element is an array of parameters
%   - For 'local_background':
%      - A cell array with N elements, each of which is an array of parameters
%      - A cell array of N cell arrays, each of which has as its first element
%        an array of parameters
%
% where N is the number of datasets.

% If not called as a callback
if nargin==1
    obj.bpin
    return
end

% Calls private functions to check the parameters are ok
[ok,mess,np,par]=plist_parse(in_par,obj.bfun);
if ~ok
    error('Input is not a valid parameter list');
end
