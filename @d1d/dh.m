function dh(w,varargin)
% DH Draws a histogram of a 1D dataset
%
%   >> dh(w)
%   >> dh(w,xlo,xhi)
%   >> dh(w,xlo,xhi,ylo,yhi)
%
% Advanced use:
%   >> dh(w,...,fig_name)       % draw with name = fig_name

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

newplot = 1;
type = 'h';
fig_name='Horace_1D';

narg=nargin-1;
if nargin>1 && ischar(varargin{end}) && ~isempty(varargin{end})
    fig_name=varargin{end};
    narg=narg-1;
end
if (narg==0)
    plot_main (newplot,type,fig_name,d1d_to_spectrum(w));
elseif (narg==2)
    plot_main (newplot,type,fig_name,d1d_to_spectrum(w),varargin{1:2});
elseif (narg==4)
    plot_main (newplot,type,fig_name,d1d_to_spectrum(w),varargin{1:4});
else
    error ('Wrong number of arguments to DL')
end
