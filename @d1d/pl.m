function pl(w,name)
% PL Draws a marker plot of a 1D dataset on an existing plot
%
%   >> pl(w)
%
% Advanced use:
%   >> pl(w,fig_name)       % plot on the fgure with name = fig_name

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

newplot = 0;
type = 'l';
fig_name='Horace_1D';
if nargin==2
    tmp = genie_figure_name(name);
    if ~isempty(tmp), fig_name=tmp; end
end
plot_main (newplot,type,fig_name,d1d_to_spectrum(w));
