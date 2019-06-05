function nw=nworkspace(map)
% Get the number of workspaces in a map object
%
%   >> nw=nworkspaces(map)
%
% Input:
% ------
%   map     IX_map object
%
% Output:
% -------
%   nw      Number of workspaces

nw=numel(map.ns);
