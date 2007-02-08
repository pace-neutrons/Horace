function plot(w,varargin)
% Draws a plot of line, markers and error bars for a 1D dataset
%
% Syntax:
%   >> plot(w)
%   >> plot(w,xlo,xhi)
%   >> plot(w,xlo,xhi,ylo,yhi)
%
% Advanced use:
%   >> plot(w,...,fig_name)       % draw with name = fig_name
%
% [Note: equivalent to the plot function 'd'; included for naming consistency
% with corresponding plot function for two and three dimensional datasets]


% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

global genie_max_spectra_1d

% Check spectrum is not too long an array
if length(w)>genie_max_spectra_1d
    error (['This function can only be used to plot ',num2str(genie_max_spectra_1d),' spectra - check length of spectrum array'])
end

de(w,varargin{:})
if nargin>1 && ischar(varargin{end}) && ~isempty(varargin{end})
    fig_name=varargin{end};
    pm(w,fig_name)
    pl(w,fig_name)
else
    pm(w)
    pl(w)
end
