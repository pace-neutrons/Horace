function xb=rebin_boundaries_description_resolve_infinities(xbounds,is_descriptor,xlo,xhi)
% Resolve -Inf and Inf in bin boundaries or rebin descriptor according to the range [xlo,xhi]
%
%   >> xb=resolve_infinities(xbounds,is_descriptor,xlo,xhi)
%
%   xbounds         Bin boundaries or rebin descriptor
%   is_descriptor   True if rebin descriptor, false if bin boundaries
%   xlo             Lower limit of data
%   xhi             Upper limit of data
%
%   xb              Bin boundaries or rebin descriptor with infinities resolved
%                   - if is a descriptor and [-Inf,0,Inf] i.e. bins unchanged, then
%                       xb=[]
%                   - There are some circumstance when there are no bins, when 
%                       xb is scalar (convention for histogram data with no data)
%
%                    e.g.  descriptor:     xbounds=[-Inf,5,10], [xlo,xhi]=[100,200]
%                          bin boundaries: xbounds=[-Inf,10], [xlo,xhi]=[100,200]
%                   then the output is a scalar, to be interpreted as no bins.
%                   Note: this circumstance can arise if only one of the outer limits
%                   is infinite, and there is just one bin (bin boundaries) or just one
%                   descriptor range (rebin descriptor). The scalar value of xb is the
%                   finite of the two limits.
%
% Assumes valid input i.e. xbounds is a valid descriptor or set of bin boundaries, and 
% both xlo and xhi are finite with xlo<xhi.

% Catch case of unchanged bins
if is_descriptor && numel(xbounds)==3 && all(xbounds==[-Inf,0,Inf])
    xb=[];
    return
end

% Other cases
xb=xbounds;
if xb(1)==-Inf || xb(end)==Inf
    if is_descriptor
        if xb(1)==-Inf
            if xb(3)>xlo
                xb(1)=xlo;
            else
                xb=xb(3:end);
                if numel(xb)<3, return, end     % convention for empty histogram data is single x value
            end
        end
        if xb(end)==Inf
            if xb(end-2)<xhi
                xb(end)=xhi;
            else
                xb=xb(1:end-2);
                if numel(xb)<3, return, end     % convention for empty histogram data is single x value
            end
        end

    else
        if xb(1)==-Inf
            if xb(2)>xlo
                xb(1)=xlo;
            else
                xb=xb(2:end);
                if numel(xb)<2, return, end     % convention for empty histogram data is single x value
            end
        end
        if xb(end)==Inf
            if xb(end-1)<xhi
                xb(end)=xhi;
            else
                xb=xb(1:end-1);
                if numel(xb)<2, return, end     % convention for empty histogram data is single x value
            end
        end
    end
end
