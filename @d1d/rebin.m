function wout = rebin(w, v1, v2, v3)
% REBIN - Rebins a 1D dataset
%
% Syntax:
%
%  wout = rebin(w1,w2)      rebin w1 with the bin boundaries of w2 (*** Note: reverse of Genie-2)
%  -------------------
%
%  wout = rebin(w1,x_array)  x_array is an array of boundaries and intervals. Linear or logarithmic
%  ------------------------ rebinning can be accommodated by conventionally specifying the rebin
%                           interval as positive or negative respectively:
%   e.g. rebin(w1,[2000,10,3000])  rebins from 2000 to 3000 in bins of 10
%
%   e.g. rebin(w1,[5,-0.01,3000])  rebins from 5 to 3000 with logarithmically spaced bins with
%                                 width equal to 0.01 the lower bin boundary 
%  The conventions can be mixed on one line:
%   e.g. rebin(w1,[5,-0.01,1000,20,4000,50,20000])
%
%  Rebinning between two limits maintaining the existing bin boundaries between those limits
%  is achieved with
%        rebin(w1,[xlo,xhi])
%
%
%  wout = rebin(w1,xlo,xhi)  retain only the data between XLO and XHI, otherwise maintaining the
%  ------------------------ existing bin boundaries. Abbreviated form of rebin(w1,[xlo,xhi])
%
%  wout = rebin(w1,xlo,dx,xhi)  Abbreviated form of rebin(w1,[xlo,dx,xhi])
%  ---------------------------
%

% The help section above should be identical to that for spectrum/rebin

if (nargin==1)
    wout = w;
elseif (nargin >= 2 & nargin <=4)
    if nargin==2
        if isa(v1,'d1d')
            vv = d1d_to_spectrum(v1);
        else
            vv = v1;
        end
    end
    if (nargin == 2)
        wtemp = rebin (d1d_to_spectrum(w), vv);
    elseif (nargin==3)
        wtemp = rebin (d1d_to_spectrum(w), v1, v2);
    elseif (nargin==4)
        wtemp = rebin (d1d_to_spectrum(w), v1, v2, v3);
    end
    wout = combine_d1d_spectrum (w, wtemp);
else
    error ('Check number of arguments')
end
