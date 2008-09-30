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
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

% Initialise output argument
wout = win;

% Dimension of input data structure
ndim=length(win.data.p);
if ndim==0  % no compacting needs to be done
    return
end

% Get section parameters and axis arrays:
[val, irange] = data_limits (win.data);

array_section=cell(1,ndim);
for i=1:ndim
    wout.data.p{i}=win.data.p{i}(irange(1,i):irange(2,i)+1);
    array_section{i}=irange(1,i):irange(2,i);
end

% Section signal, variance and npix arrays
wout.data.s = win.data.s(array_section{:});
wout.data.e = win.data.e(array_section{:});
wout.data.npix = win.data.npix(array_section{:});


%==================================================================================================
function [val, n] = data_limits (din)
% Get limits of the data in an n-dimensional dataset, that is, find the
% coordinates along each of the axes of the smallest cubiod that contains
% bins with non-zero values of contributing pixels.
%
% Syntax:
%   >> [val, n] = data_limits (din)
%
% Input:
% ------
%   din     Input dataset structure
%
% Output:
% -------
%   val     (2 x ndim) array, where ndim = dimension of dataset,containing
%           the lower and upper limits of the bin boundaries of the dataset.
%           isempty(val)=1 if there is no data in the dataset
%   
%   n       (2 x ndim) array containing the lower and upper indices of the 
%           elements along each axis
%           isempty(n)=true if there is no data in the dataset

% Original author: T.G.Perring
%
% $Revision: 57 $ ($Date: 2005-07-28 14:18:40 +0100 (Thu, 28 Jul 2005) $)
%
% Horace v0.1   J. van Duijn, T.G.Perring


s = sum_dimensions(din.npix);

ndim = length(din.p);
val = zeros(2,ndim);
n = zeros(2,ndim);
for i=1:ndim
    lis = find(s{i}~=0);
    if isempty(lis); val=[]; n=[]; return; end;
    n(1,i)=lis(1);
    n(2,i)=lis(end);
    val(1,i)=din.p{i}(1);
    val(2,i)=din.p{i}(lis(end)+1);
end
