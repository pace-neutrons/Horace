function [sout, eout] = rebin_3d_y_hist_matlab (x, s, e, xout)
% Rebins histogram data along axis iax=2 of an IX_dataset_nd with dimensionality ndim=3.
%
%   >> [sout, eout] = rebin_3d_y_hist_matlab (x, s, e, xout)
%
% Input:
% ------
%   x       Rebin axis bin boundaries
%   s       Signal array
%   e       Standard deviations on signal array
%   xout    Output rebin axis bin boundaries
%
% Output:
% -------
%   sout    Rebinned signal
%   eout    Standard deviations on rebinned signal
% 
% Assumes that the intensity and error are for a distribution (i.e. signal per unit along the axis)
% Assumes that input x and xout are strictly monotonic increasing

iax=2;
ndim=3;

% Perform checks on input parameters and initialise output arrays
% ---------------------------------------------------------------
mx=numel(x)-1;
sz=[size(s),ones(1,ndim-numel(size(s)))];   % this works even if ndim=1, i.e. ones(1,-1)==[]
if mx<1 || sz(iax)~=mx || numel(size(s))~=numel(size(e)) || any(size(s)~=size(e))
    error('Check sizes of input arrays')
end

nx=numel(xout)-1;
if nx<1
    error('Check size of output axis axis')
end
sz_out=sz;
sz_out(iax)=nx;

sout=zeros(sz_out);     % trailing singletons in sz do not matter - they are squeezed out in the call to zeros
eout=zeros(sz_out);


% Perform rebin
% -------------
iin = max(1, upper_index(x, xout(1)));
iout= max(1, upper_index(xout, x(1)));
if iin==mx+1 || iout==nx+1,  return, end    % guarantees that there is an overlap between x and xout

while 1>0
    sout(:,iout,:) = sout(:,iout,:) + (min(xout(iout+1),x(iin+1)) - max(xout(iout),x(iin))) * s(:,iin,:);
    eout(:,iout,:) = eout(:,iout,:) + ((min(xout(iout+1),x(iin+1)) - max(xout(iout),x(iin))) * e(:,iin,:)).^2;
    if xout(iout+1) >= x(iin+1)
        if iin<mx
            iin = iin + 1;
        else
            sout(:,iout,:) = sout(:,iout,:) / (xout(iout+1)-xout(iout));		% end of input array reached
            eout(:,iout,:) = sqrt(eout(:,iout,:)) / (xout(iout+1)-xout(iout));
            break
        end
    else
        sout(:,iout,:) = sout(:,iout,:) / (xout(iout+1)-xout(iout));
        eout(:,iout,:) = sqrt(eout(:,iout,:)) / (xout(iout+1)-xout(iout));
        if iout<nx
            iout = iout + 1;
        else
            break
        end
    end
end
