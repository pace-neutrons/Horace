function [par,argout,present]=test_parse_arguments (varargin)
%
% arglist = struct('background',[12000,18000], ...    % argument names and default values
%     'normalise', 1, ...
%     'modulation', 0, ...
%     'output', 'data.txt');
% flags = {'normalise','modulation'};                 % arguments which are logical flags

arglist = struct('pix',0);
flags = {'pix'};

[par,argout,present] = parse_arguments(varargin,arglist,flags);


