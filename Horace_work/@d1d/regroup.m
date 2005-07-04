function wout = regroup(w, v1, v2, v3)
% REGROUP  Rebins so that the new bin boundaries are
%          always coincident with boundaries in the input 1D dataset. This avoids
%          correlated error bars between the contents of the bins.
%
% Syntax :
%
%   >> wout = regroup (w1,xlo,dx,xhi)
%
%   >> wout = regroup (w1,[xlo,dx,xhi])
%
% If DX +ve: then the bins are linear i.e. wout.x(i+1) >= wout.x(i) + dx
% If DX -ve: then the bins are logarithmic i.e. wout.x(i+1) >= wout.x(i)*(1+|dx|)
%
% The value of wout.x(i+1) is chosen to be the smallest w1.x(j) that satisfies the RHS of the
% equations above. Each of the new bin bondaries therefore always conincides with an input
% bin boundary. This ensures that the data in output bins are uncorrelated with the
% data in its neighbours. There has to be at least one input histogram bin entirely
% contained within the range XLO to XHI i.e.
%
%          xhi =< wout.x(1) < wout.x(nout) =< xhi
%

% The help section above should be identical to that for spectrum/regroup

if (nargin==1)
    wout = w;
elseif (nargin == 2|nargin == 4)
    if (nargin==2)
        wtemp = regroup (d1d_to_spectrum(w), v1);
    elseif (nargin==4)
        wtemp = regroup (d1d_to_spectrum(w), v1, v2, v3);
    end
    wout = combine_d1d_spectrum (w, wtemp);
else
    error ('Check number of arguments')
end
