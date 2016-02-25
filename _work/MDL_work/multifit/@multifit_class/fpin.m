function [par,np] = fpin(obj, in_par)
% Field containing the initial parameters for the foreground fit function(s)
%
% Valid inputs are:
%   - For 'global_foreground':
%      - An array of parameters 
%      - A cell array whose first element is an array of parameters
%   - For 'local_foreground':
%      - A cell array with N elements, each of which is an array of parameters
%      - A cell array of N cell arrays, each of which has as its first element
%        an array of parameters
%
% where N is the number of datasets.

% If not called as a callback
if nargin==1
    obj.fpin
    return
end

% Calls private functions to check the parameters are ok
[ok,mess,np,par]=plist_parse(in_par,obj.ffun);
if ~ok
    error('Input is not a valid parameter list');
end
