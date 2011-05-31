function [ok,rebin_descriptor,any_dx_zero,mess]=rebin_descriptor_check(varargin)
% Check rebin descriptor has valid format, and reteurns in standard form [x1,dx1,x2,dx2,x3,...]
%
%   xlo,xhi
%   xlo,dx,xhi
%   [xlo,xhi]
%   [xlo,dx,xhi]
%   [x1,dx1,x2,dx2,x3,...]
%
%   Require that x1<x2<x3... and that if dx1<0 then dx1>0, dx2<0 then dx2>0 ...

ok=false;
rebin_descriptor=[];
any_dx_zero=false;
mess='';
if nargin==1 && isnumeric(varargin{1}) && ~isscalar(varargin{1})
    if numel(varargin{1})>=3 && rem(numel(varargin{1}),2)==1
        if all(diff(varargin{1}(1:2:end)))>0    % strictly monotonic increasing
            if all(varargin{1}(1:2:end-1)>0 | varargin{1}(2:2:end-1)>=0)
                ok=true;
                if any(varargin{1}(2:2:end)==0), any_dx_zero=true; end
                rebin_descriptor=varargin{1}(:)';
            else
                mess='Binning descriptor: cannot have logarithmic bins for negative axis values';
            end
        else
            mess='Binning descriptor: bin boundaries must be strictly monotonic increasing';
        end
    elseif numel(varargin{1})==2
        if varargin{1}(2)>varargin{1}(1)
            ok=true;
            rebin_descriptor=varargin{1}(:)';
        else
            mess='Binning descriptor: upper limit must be greater than lower limit';
        end
    else
        mess='Check length of rebin descriptor array';
    end
    
elseif nargin==2 && isnumeric(varargin{1}) && isnumeric(varargin{2}) &&...
        isscalar(varargin{1})  && isscalar(varargin{2})
    if varargin{2}>varargin{1}
        ok=true;
        rebin_descriptor=[varargin{1},varargin{2}];
    else
        mess='Binning descriptor: upper limit must be greater than lower limit';
    end
    
elseif nargin==3 && isnumeric(varargin{1}) && isnumeric(varargin{2}) && isnumeric(varargin{3}) &&...
        isscalar(varargin{1})  && isscalar(varargin{2})  && isscalar(varargin{3})
    if varargin{3}>varargin{1}
        if varargin{1}>0 || varargin{2} >=0
            ok=true;
            rebin_descriptor=[varargin{1},varargin{2},varargin{3}];
        else
            mess='Binning descriptor: cannot have logarithmic bins for negative axis values';
        end
    else
        mess='Binning descriptor: bin boundaries must be strictly monotonic increasing';
    end
    
else
    mess='Check number and type of rebin descriptor parameter(s)';
end
