function [ok,xbounds,any_dx_zero,mess]=rebin_descriptor_check(varargin)
% Check rebin descriptor has valid format, and returns in standard form [x1,dx1,x2,dx2,x3,...]
%
% If one integration axis only
%   xlo,xhi
%   xlo,dx,xhi
% For one or more integration axes:
%   [xlo,xhi]
%  if isdescriptor:
%   [xlo,dx,xhi]
%   [x1,dx1,x2,dx2,x3,...]  % descriptor: requires that x1<x2<x3... and that if dx1<0 then dx1>0, dx2<0 then dx2>0 ...
%  else
%   [x1,x2,x3,...]          % actual boundaries: x1<x2<x3<...

ok=false;
xbounds=[];
any_dx_zero=false;
mess='';
% -------------------------------------------------------------------------------------------------
% xlo,xhi  - only valid if a single rebin axis
if numel(varargin)==2 && isnumeric(varargin{1}) && isnumeric(varargin{2}) &&...
        isscalar(varargin{1})  && isscalar(varargin{2})
    if varargin{2}>varargin{1}
        ok=true;
        xbounds={[varargin{1},varargin{2}]};
    else
        mess='Binning descriptor: upper limit must be greater than lower limit';
    end
    
% -------------------------------------------------------------------------------------------------
% xlo,dx,xhi  - only valid if a single rebin axis
elseif numel(varargin)==3 && isnumeric(varargin{1}) && isnumeric(varargin{2}) && isnumeric(varargin{3}) &&...
    isscalar(varargin{1})  && isscalar(varargin{2})  && isscalar(varargin{3})
    if varargin{3}>varargin{1}
        if varargin{1}>0 || varargin{2} >=0
            ok=true;
            xbounds={[varargin{1},varargin{2},varargin{3}]};
        else
            mess='Binning descriptor: cannot have logarithmic bins for negative axis values';
        end
    else
        mess='Binning descriptor: bin boundaries must be strictly monotonic increasing';
    end
    
% -------------------------------------------------------------------------------------------------
% one or more vectors
elseif numel(varargin)>=1
    xbounds=cell(1,numel(varargin));
    any_dx_zero=false(1,numel(varargin));
    for i=1:numel(varargin)
        if isnumeric(varargin{i}) && ~isscalar(varargin{i})
            if numel(varargin{i})>=3 && rem(numel(varargin{i}),2)==1
                if all(diff(varargin{i}(1:2:end)))>0    % strictly monotonic increasing
                    if all(varargin{i}(1:2:end-1)>0 | varargin{i}(2:2:end-1)>=0)
                        ok=true;
                        if any(varargin{i}(2:2:end)==0), any_dx_zero(i)=true; end
                        xbounds{i}=varargin{i}(:)';
                    else
                        mess='Binning descriptor: cannot have logarithmic bins for negative axis values';
                    end
                else
                    mess='Binning descriptor: bin boundaries must be strictly monotonic increasing';
                end
            elseif numel(varargin{i})==2
                if varargin{i}(2)>varargin{i}(1)
                    ok=true;
                    xbounds{i}=varargin{i}(:)';
                else
                    mess='Binning descriptor: upper limit must be greater than lower limit';
                end
            else
                mess='Check length of rebin descriptor array';
            end
        end
    end
        
% -------------------------------------------------------------------------------------------------
else
    mess='Check number and type of rebin descriptor parameter(s)';
end
