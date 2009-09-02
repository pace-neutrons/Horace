function wout = compact (win)
% Squeezes the data range in an sqw object to eliminate empty bins
%
% Syntax:
%   >> wout = compact(win)
%
% Input:
% ------
%   win         Input object 
%
% Output:
% -------
%   wout        Output object, with length of axes reduced to yield the
%               smallest cuboid that contains the non-empty bins.
%

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

% Initialise output argument
wout = win;

% Dimension of input data structure
ndim=length(win.data.p);
if ndim==0  % no compacting needs to be done
    return
end

% Get section parameters and axis arrays:
[val, irange] = data_bin_limits (win.data);

array_section=cell(1,ndim);
for i=1:ndim
    wout.data.p{i}=win.data.p{i}(irange(1,i):irange(2,i)+1);
    array_section{i}=irange(1,i):irange(2,i);
end

% Section signal, variance and npix arrays
wout.data.s = win.data.s(array_section{:});
wout.data.e = win.data.e(array_section{:});
wout.data.npix = win.data.npix(array_section{:});
