function [x_out, ok, mess]=bin_boundaries_from_descriptor (xbounds, x_in)
% Get new x bin boundaries from a bin boundary descriptor
%
%   >> [x_out, ok]=bin_boundaries_from_descriptor (xbounds)
%   >> [x_out, ok]=bin_boundaries_from_descriptor (xbounds, x_in)
%
% Input:
% ------
%   xbounds     Histogram bin boundaries descriptor:
%                   (x_1, del_1, x_2,del_2 ... x_n-1, del_n-1, x_n)
%                   Bin from x_1 to x_2 in units of del_1 etc.
%                       del > 0: linear bins
%                       del < 0: logarithmic binning
%                       del = 0: Use bins from input array
%                   [If only two elements, then interpreted as lower and upper bounds, with DEL=0]
%
%   x_in        Input x-array bin boundaries - only used where DEL=0 for one of the rebin ranges
%
% Output:
% --------
%   x_out       Bin boundaries for rebin array.
%
%   ok          =true  if no problems
%               =false if a problem (and x_out is set to [])
%
%   mess        Error message
%
%   if ok is omitted, then the error message is printed to the screen.

%  T.G.Perring  2011-07-24  Direct translation of my Fortran in mgenie dated 2002-08-15
%                           Consequently, probably could be made more efficient.
%
%                           Tests on large x_in arrays with shortish xbounds suggest that
%                           matlab is only a factor of two or so slower. (7.11, quad core Win7)

small=1.0e-10;

n_out_filled=false;
x_out_filled=false;
checked_x_in=false;

% Perform checks on input parameters:
% ---------------------------------------
mx = numel(xbounds);
if (mx < 2) || (mx > 2 && mod(mx,2) ~= 1)
    x_out=[]; ok=false; mess = 'Check size of xbounds array';
    if nargout==1, error(mess), else return, end
end

while ~(n_out_filled && x_out_filled)
    if n_out_filled
        x_out=zeros(1,n_out);   % second pass; preassign x_out
    end

    ntot = 1;	% total number of bin boundaries in output array (accumulates during algorithm)
    for i = 1:floor(mx/2)
        if mx ~= 2
            xlo = xbounds(2*i-1);
            del = xbounds(2*i);
            xhi = xbounds(2*i+1);
        else
            xlo = xbounds(1);
            del = 0;
            xhi = xbounds(2);
        end
        
        if xhi <= xlo
            x_out=[]; ok=false; mess = 'Check boundaries strictly monotonically increasing';
            if nargout==1, error(mess), else return, end
        end
        
        if del > 0
            n = floor((xhi-xlo)/del - small);
            if (xlo+n*del < xhi), n=n+1; end	% n = no. bin boundaries in addition to XLO (i.e. includes XHI)
            if n_out_filled
                x_out(ntot) = xlo;
                if n > 1
                    x_out(ntot+1:ntot+n-1) = xlo + del*(1:n-1);
                end
            end
            ntot = ntot + n;
        elseif del < 0
            if xlo <= 0
                x_out=[]; ok=false; mess = 'Logarithmic bins starting with XLO <= 0 forbidden';
                if nargout==1, error(mess), else return, end
            end
            logdel = log(1-del);
            n = floor(log(xhi/xlo)/logdel - small);
            if xlo*exp(n*logdel) < xhi, n=n+1; end
            if n_out_filled
                x_out(ntot) = xlo;
                if n > 1
                    x_out(ntot+1:ntot+n-1) = xlo*exp((1:n-1)*logdel);
                end
            end
            ntot = ntot + n;
        else
            % Check that input array is present and monotonically increasing:
            if ~checked_x_in
                checked_x_in = true;
                if ~exist('x_in','var')
                    x_out=[]; ok=false; mess = 'No input x array provided to supply bin boundaries';
                    if nargout==1, error(mess), else return, end
                end
                m_in = numel(x_in);
                if m_in > 1
                    if min(x_in(2:m_in)-x_in(1:m_in-1)) <= 0
                        x_out=[]; ok=false; mess = 'Input x array is not strictly monotonic increasing';
                        if nargout==1, error(mess), else return, end
                    end
                end
            end
            % Get lower and upper indicies of input array of bin boundaries such that xlo < x_in(imin) < x_in(imax) < xhi:
            imin = lower_index(x_in, xlo);
            imax = upper_index(x_in, xhi);
            if imin <= m_in && imax >= 1
                if (x_in(imin)==xlo), imin = imin + 1; end
                if (x_in(imax)==xhi), imax = imax - 1; end
                n = imax - imin + 2;	% n is the number of extra bin boundaries that will be added (including XHI)
            else
                n = 1;
            end
            if n_out_filled
                x_out(ntot) = xlo;
                if (n > 1), x_out(ntot+1:ntot+n-1) = x_in(imin:imax); end	% ntot+n => ntot+n-1 TGP (2003-12-05)
            end
            ntot = ntot + n;
        end
    end
    if ~n_out_filled
        n_out = ntot;
        n_out_filled=true;
    else
        x_out(ntot) = xhi;
        x_out_filled=true;
    end
end
ok=true;
mess='';
