function [table,t_av,fwhh]=sampling_table(moderator,ei,varargin)
% Create lookup table from which to create random sampling of moderator function
%
%   >> [a,t_av]=sampling_table(moderator,ei)        % sampling_table for ei (default number of points)
%   >> [a,t_av]=sampling_table(moderator,ei,npnt)   % with specified number of points (npnt>=2)
%   >> [a,t_av]=sampling_table(...,'fast')          % faster but less accurate algorithm
%
% Return fwhh as well (can be rather slower)
%   >> [a,t_av,fwhh]=sampling_table(...)
%
% Input:
% -------
%   moderator   IX_moderator object
%   ei          Incident energy (mev)
%   npnt        [Optional] Number of points in lookup table.
%               If omitted, set to 100
%   opt         [Optional] if 'fast', use faster but less accurate algorithm
%
% Output:
% -------
%   a           Look-up table to convert a random number from uniform distribution
%              in the range 0 to 1 into reduced time deviation 0 <= t_red <= 1
%              Convert to true time t = t_av * (t_red/(1-t_red)) [Column vector]
%   t_av        First moment of pulse shape (microseconds) 
%   fwhh        Full width half height (microseconds)

npnt_default=100;

if ~isscalar(moderator), error('Function only takes a scalar object'), end

% Optional argument
if nargin>=3 && is_string(varargin{end})
    if strcmpi(varargin{end},'fast')
        fast=true;
        narg=nargin-1;
    else
        error('Unrecognised optional argument')
    end
else
    fast=false;
    narg=nargin;
end

% Number of points
if narg==2
    npnt=npnt_default;
elseif narg>2
    npnt=varargin{1};
else
    error('Check number of sampling points in the table to be constructed')
end

model=moderator.pulse_model;
if strcmp(model,'ikcarp')           % Raw Ikeda Carpenter
    [table,t_av]=sampling_table_ikcarp(moderator.pp,ei,npnt,fast);
    
elseif strcmp(model,'ikcarp_param') % Ikeda-Carpenter with parametrised tauf, taus, R
    [table,t_av]=sampling_table_ikcarp_param(moderator.pp,ei,npnt,fast);
    
else
    error(['Unrecognised pulse model ''',model,''''])
end

% Calculate fwhh only if requested (can take some time)
if nargout==3
    [~,~,fwhh]=pulse_width(moderator,ei);
end
