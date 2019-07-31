function [xb,ok,mess]=rebin_boundaries_description_resolve_inf_(xbounds,is_descriptor,xlo,xhi)
% Resolve -Inf and Inf in bin boundaries or rebin descriptor according to the range [xlo,xhi]
%
%   >> [xb,ok,mess]=rebin_boundaries_description_resolve_inf(xbounds,is_descriptor,xlo,xhi)
%
% Input:
% ------
%   xbounds         Bin boundaries or rebin descriptor
%   is_descriptor   True if rebin descriptor, false if bin boundaries
%   xlo             Lower limit of data
%                  (histogram data: lowest bin boundary; point data: lowest point position)
%   xhi             Upper limit of data
%                  (histogram data: highest bin boundary; point data: highest point position)
%
% Output:
% -------
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
%   ok              =true if all infinities could be resolved; =false otherwise
%                   if false,then xb=[] and mess will be filled.
%   mess            ='' if OK; error message if not.
%
% Assumes valid input i.e. xbounds is a valid descriptor or set of bin boundaries, and
% both xlo and xhi are finite with xlo<xhi.


xb=xbounds;
ok=true;
mess='';
if xb(1)==-Inf || xb(end)==Inf
    if is_descriptor
        if numel(xbounds)==3 && isinf(xbounds(1)) && isinf(xbounds(3))
            % Catch case of form [-Inf,dx,Inf]:
            if xbounds(2)==0
                xb=[];
            elseif xbounds>0
                xb=[low_limit(xlo,0,xbounds(2)),xbounds(2),high_limit(xhi,0,xbounds(2))];
            else
                if xlo>0
                    xb=[low_limit(xlo,1,xbounds(2)),xbounds(2),high_limit(xhi,1,xbounds(2))];
                else
                    xb=[]; ok=false; mess='If lower limit is less than or equal to zero, the rebin descriptor [-Inf,dx,Inf] with dx<0 is invalid';
                    return
                end
            end
        else
            % Other cases
            if xb(1)==-Inf
                if xb(3)>xlo
                    [xb(1),ok]=low_limit(xlo,xb(3),xb(2));
                    if ~ok, xb=[]; mess='Unable to resolve rebin descriptor beginning [-Inf,dx,...] - check dx and lower limit of data'; return, end
                else
                    xb=xb(3:end);
                    if numel(xb)<3, return, end % convention for empty histogram data is single x value
                end
            end
            if xb(end)==Inf
                if xb(end-2)<xhi
                    [xb(end),ok]=high_limit(xhi,xb(end-2),xb(end-1));
                    if ~ok, xb=[]; mess='Unable to resolve rebin descriptor ending [...dx,Inf] - check dx and upper limit of data'; return, end
                else
                    xb=xb(1:end-2);
                    if numel(xb)<3, return, end % convention for empty histogram data is single x value
                end
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

%--------------------------------------------------------------------------------------------------
function [xlo,ok]=low_limit(x,xref,dx)
% Carefully construct a lower limit from a bin descriptor to avoid rounding errors
%
%   >> xout=low_limit(x,xref,delta)
%
%   x       Lowest value for which must have xout>=x
%   xref    Reference value from which to construct bins with width dx
%   dx      Bin step
%            dx +ve: equal bin sizes 
%            dx -ve: logarithmic bins between corresponding limits
%   xlo     Value such that 

ok=true;
if dx==0
    xlo=x;
elseif dx>0
    xlo=xref+dx*floor((x-xref)/dx);
    if xlo>x
        xlo=xlo-dx;
    elseif xlo<x && xlo+dx<=x
        xlo=xlo+dx;
    end
elseif dx<0 && x>0 && xref>0
    n=floor((log(xref/x)/log(1+abs(dx))));
    xlo=exp(log(xref)-n*log(1+abs(dx)));
    if xlo>x
        xlo=xlo/(1+abs(dx));
    elseif xlo<x && xlo*(1+abs(dx))<=x
        xlo=xlo*(1+abs(dx));
    end
else
    xlo=[];
    ok=false;
    if nargout==1, error('IX_dataset:invalid_argument','Invalid input'); end
end

%--------------------------------------------------------------------------------------------------
function [xhi,ok]=high_limit(x,xref,dx)
% Carefully construct an upper limit from a bin descriptor to avoid rounding errors
%
%   >> xout=high_limit(x,xref,delta)
%
%   x       Highest value for which must have xout>=x
%   xref    Reference value from which to construct bins with width dx
%   dx      Bin step
%            dx +ve: equal bin sizes 
%            dx -ve: logarithmic bins between corresponding limits
%   xlo     Value such that 

ok=true;
if dx==0
    xhi=x;
elseif dx>0
    xhi=xref+dx*ceil((x-xref)/dx);
    if xhi<x
        xhi=xhi+dx;
    elseif xhi>x && xhi-dx>=x
        xhi=xhi-dx;
    end
elseif dx<0 && x>0 && xref>0
    n=ceil((log(x/xref)/log(1+abs(dx))));
    xhi=exp(log(xref)+n*log(1+abs(dx)));
    if xhi<x
        xhi=xhi*(1+abs(dx));
    elseif xhi>x && xhi/(1+abs(dx))>=x
        xhi=xhi/(1+abs(dx));
    end
else
    xhi=[];
    ok=false;
    if nargout==1, error('IX_dataset:invalid_argument','Invalid input'); end
end
