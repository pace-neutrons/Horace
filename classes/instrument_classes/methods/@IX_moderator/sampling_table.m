function [table,t_av,fwhh,profile]=sampling_table(moderator,ei,varargin)
% Create lookup table from which to create random sampling of moderator function
%
% Sampling_table for ei (default number of points):
%   >> [table,t_av]=sampling_table(moderator,ei)        
%
% With specified number of points (npnt>=2)
%   >> [table,t_av]=sampling_table(moderator,ei,npnt)
%
% Faster but less accurate algorithm for lookup table
%   >> [table,t_av]=sampling_table(...,'fast')
%
% Return fwhh as well (can be rather slower)
%   >> [a,t_av,fwhh]=sampling_table(...)
%
% Return profile lookup table as well
%   >> [table,t_av,fwhh,profile]=sampling_table(...)
%
% Input:
% -------
%   moderator   IX_moderator object
%   ei          Incident energy (mev)
%   npnt        [Optional] Number of points in lookup table.
%               If omitted, set to 100
%               The size of the profile table is 5*npnt
%   opt         [Optional] if 'fast', use faster but less accurate algorithm
%
% Output:
% -------
%   table       Look-up table to convert a random number from uniform distribution
%              in the range 0 to 1 into reduced time deviation 0 <= t_red <= 1
%              Convert to true time t = t_av * (t_red/(1-t_red)) [Column vector]
%   t_av        First moment of pulse shape (microseconds) 
%   fwhh        Full width half height (microseconds)
%   profile     Lookup table of profile, normalised to peak height=1, for
%              equally spaced intervals of t_red in the range 0 =< t_red =< 1
%              (Column vector)


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
if nargout>=3
    [~,~,fwhh]=pulse_width(moderator,ei);
end

% Calculate profile if requested
if nargout==4
    npro=5*npnt;
    profile=zeros(npro,1);
    t_red=[0;(1:npro-2)'/(npro-1)];     % omit last point; assume pulse height zero at t_red=1
    profile(1:end-1,1)=pulse_shape(moderator,ei,t_av*(t_red./(1-t_red)));
    profile=profile/max(profile);
end
