function [ok,xbounds,any_dx_zero,mess]=rebin_descriptor_check(nax,varargin)
% Check rebin descriptor has valid format, and returns in standard form [x1,dx1,x2,dx2,x3,...]
%
% Input:
% ------
%   nax                     % Number of rebin descriptors that is expected
%
%   One rebin axis:
%     [] or 0               % Leave bins as they are
%     xlo,xhi               % Defines single bin, equivalent to [xlo,xhi] (single axis only)
%     xlo,dx,xhi            % Rebin descriptor: equivalent to [xlo,dx,xhi]
%     x1,dx1,x2,dx2,x3,...  % Rebin descriptor: equivalent to [x1,dx1,x2,dx2,x3,...]
%
%   Any number of rebin axes:
%     xdescr1, xdescr2,...  % Set of rebin descriptors i.e. vectors that define bin boundaries
%                           %(one vector of bin boundaries per dimension).
%                           % General form:
%                           %   xbins=[x1,dx1,x2,dx2,x3,...] where x1<x2<x3... and that 
%                           %   dx +ve: equal bin sizes between corresponding limits
%                           %   dx -v2: logarithmic bins between corresponding limits
%                                    (note: if dx1<0 then dx1>0, dx2<0 then dx2>0 ...)
%                           %   dx=0  : retain existing bins between corresponding limits
%                           % Special cases:
%                           %   xbins=[] or 0     - leave binning as it currently is
%
% Output:
% -------
%   ok          true if no problems, false if error found in input e.g. not strictly monotonic boundaries
%   xbounds     cell array of rebin descriptor vectors {xbins1, xbins2,...}; [] if ok==false
%   any_dx_zero Logical array; en element is true if one or more dx in the corresponding
%               descriptor is zero.
%   mess        Error message of ok==false (empty otherwise)


% If no bins given, return [] for each rebin axis
if numel(varargin)==0
    xbounds=cell(1,nax);
    for i=1:nax
        xbounds{i}=[];
    end
    any_dx_zero=true(1,nax);
    ok=true; mess='';
    return
end

% Parse input
if nax==1
    if ~(numel(varargin)==1 && (isempty(varargin{1}) || (isnumeric(varargin{1})&&isvector(varargin{1}))))
        % input is not a single empty argumnent or a numeric vector, so must be non empty numeric scalars
        xvals=zeros(1,numel(varargin));
        for i=1:numel(varargin)
            if ~isempty(varargin{i}) && isnumeric(varargin{i}) && isscalar(varargin{i})
                xvals(i)=varargin{i};
            else
                ok=false; xbounds=[]; any_dx_zero=false;
                mess='Check bin boundary descriptor is a numeric vector or list of scalars';
                return
            end
        end
        [ok,xvals,any_dx_zero,mess]=check_boundaries(xvals);
        if ok
            xbounds={xvals};
        else
            xbounds=[];
        end
        return
    end
end

if nax==numel(varargin)
xbounds=cell(1,nax);
any_dx_zero=false(1,nax);
for i=1:nax
    [ok,xbounds{i},any_dx_zero(i),mess]=check_boundaries(varargin{i});
    if ~ok, xbounds=[]; any_dx_zero=false; return, end
end
else
    ok=false; xbounds=[]; any_dx_zero=false;
    mess='Check number of bin boundary descriptors matches number of rebin axes';
end

% -------------------------------------------------------------------------------------------------
function [ok,xbounds,any_dx_zero,mess]=check_boundaries(xbounds)
% Check boundary descriptors are OK
if isempty(xbounds)
    ok=true; xbounds=[]; any_dx_zero=true; mess=''; return    % force xbounds to be empty numeric
elseif isnumeric(xbounds)
    if isscalar(xbounds) && xbounds==0
        ok=true; xbounds=[]; any_dx_zero=true; mess=''; return    % force xbounds to be empty numeric
    elseif numel(xbounds)==2 && isvector(xbounds)
        if xbounds(1)<xbounds(2)
            xbounds=[xbounds(1),0,xbounds(2)];
            ok=true; mess=''; any_dx_zero=true;
        else
            ok=false; xbounds=[]; any_dx_zero=false;
            mess='Upper limit must be greater than lower limit in bin boundary descriptor';
        end
    elseif numel(xbounds)>=3 && isvector(xbounds) && rem(numel(xbounds),2)==1
        if all(diff(xbounds(1:2:end)))>0    % strictly monotonic increasing
            if all(xbounds(1:2:end-1)>0 | xbounds(2:2:end-1)>=0)
                ok=true; mess='';
                if any(xbounds(2:2:end)==0)
                    any_dx_zero=true;
                else
                    any_dx_zero=false;
                end
                if size(xbounds,1)>1, xbounds=xbounds'; end     % make row vector
            else
                ok=false; xbounds=[]; any_dx_zero=false;
                mess='Binning descriptor: cannot have logarithmic bins for negative axis values';
            end
        else
            ok=false; xbounds=[]; any_dx_zero=false;
            mess='Bin ranges in rebin descriptor must be strictly monotonic increasing';
        end        
    else
        ok=false; xbounds=[]; any_dx_zero=false;
        mess='Check rebin descriptor has correct number of elements';
    end
else
    ok=false; xbounds=[]; any_dx_zero=false;
    mess='Rebin descriptor must form numeric vector';
end
