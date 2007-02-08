function p(w,varargin)
% Draws line, markers and error bars for a 1D dataset on an existing plot
%
%   >> p(w)
%
% Advanced use:
%   >> p(w,fig_name)       % draw with name = fig_name

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

pe(w,varargin{:})
pm(w,varargin{:})
pl(w,varargin{:})
