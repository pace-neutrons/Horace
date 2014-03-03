function [xcent,xpeak,fwhh,xneg,xpos,ypeak]=peaks_cwhh(w,varargin)
% Find centre of half height of the peaks in a IX_dataset_1d object
% Simple function that assumes that all data points are positive.
%
%   >> [xcent,xpeak,fwhh,xneg,xpos,ypeak]=peaks_cwhh(w)      % centre half-height
%   >> [xcent,xpeak,fwhh,xneg,xpos,ypeak]=peaks_cwhh(w,fac)  % centre of fac*height (fac<1)
%
%   >> [...]=peaks_cwhh(...,'opt1',arg1,'opt2',arg2,...)
%
% Input:
% ------
%   w       IX_dataset_1d or array of IX_dataset_1d in which to find the peak
%   fac     Factor of peak height at which to determine the centre-height position
%           (default=0.5 i.e. centre-fwhh)
%
% Peak search options:
%         'area', amin      Keep only those peaks whose area is at least the given value
%     'rel_area', rel_amin  Keep only those peaks whose area is at least a fraction
%                          rel_amin of the largest peak
%       'height', hmin      Keep only those peaks whose height is at least the given value
%   'rel_height', rel_hmin  Keep only those peaks whose height is at least a fraction
%                          rel_hmin of the tallest peak
%
% In addition with the above, or on their own:
%           'na', nmax      Keep nmax peaks with largest areas (cannot use with 'nh')
%           'nh', nmax      Keep nmax tallest peaks (cannot use with 'na')
%
% Output:
% -------
%   xcent   Centre(s) of factor-of-height [column vector]
%   xpeak   Peak position(s) [column vector]
%   fwhh    Full width(s) at factor-of-height [column vector]
%   xneg    Position(s) of factor-of-height on lower x side [column vector]
%   xpos    Position(s) of factor-of-height on higher x side [column vector]
%   ypeak   Peak height(s) [column vector]
%
% If no peaks were found, then xcent,...ypeak are set to empty

narg=numel(varargin);
if rem(narg,2)==1 && isnumeric(varargin{1})
    fac=varargin{1};
    ind_opt_beg=2;
elseif rem(narg,2)==0
    fac=0.5;
    ind_opt_beg=1;
else
    error('Check number and type of input arguments')
end

if numel(w)~=1
    error('Method works only for a single IX_dataset_1d')
end

if length(w.x)~=length(w.signal)
    xc=0.5*(w.x(1:end-1)+w.x(2:end));
else
    xc=w.x;
end
[xcent,xpeak,fwhh,xneg,xpos,ypeak]=peaks_cwhh_xye(xc,w.signal,w.error,fac,varargin{ind_opt_beg:end});
