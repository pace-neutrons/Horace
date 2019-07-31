function range_new = round_range (range)
% Round the lower and upper limits of a range that still enclose the range
%
%   >> range_out = round_range (range)
%
% The purpose is to make plot limits simple

dx = range(2) - range(1);
[mant,expon] = mant_and_expon(dx,2);
interval = step(mant);

mant_lo = mant_for_expon(range(1),expon);
mant_hi = mant_for_expon(range(2),expon);
range_new = (10^expon) *...
    [interval*floor(mant_lo/interval), interval*ceil(mant_hi/interval)];


%---------------------------------------------------------------------------------
function mant = mant_for_expon (x,expon)
% Return the mantissa corresponding to a particular exponent
%
%   >> mant = mant_for_expon (x,expon)

% This should be exact if x,expon such that mant is integer
if expon>0
    mant = x / 10^expon;
elseif expon<0
    mant = x * 10^(-expon);
else
    mant = x;
end


%---------------------------------------------------------------------------------
function [mant,expon] = mant_and_expon (x,nsigfig)
% Return mantissa and exponent
%
%   >> [mant,expon] = mant_and_expon (x,nsigfig)
%   >> [mant,expon] = mant_and_expon (x)          % defaults to nsigfig = 1
%
% so that  x = mant * 10^expon   with sigfig figures to left of decimal point

if nargin==1, nsigfig=1; end
log10x = log10(x);
log10mant = mod(log10x,1) + (nsigfig-1);   % range sigfig-1 <= mant < sigfig
mant = 10^log10mant;
expon = round(log10x-log10mant);


%---------------------------------------------------------------------------------
function dx = step(x)
% Return step size for rounding for 10 <= x <100
if x<20
    dx = 2;
elseif x<40
    dx = 4;
elseif x<60
    dx = 5;
else
    dx = 10;
end
