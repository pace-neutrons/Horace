function [ok,xbounds,any_dx_zero,mess]=rebin_boundaries_check(nax,varargin)
% Check that the rebin boundaries are valid.
%
%   >> [ok,xbounds,any_dx_zero,mess]=rebin_boundaries_check(nax)        % sets output boundaries to [] for all nax axes 
%   >> [ok,xbounds,any_dx_zero,mess]=rebin_boundaries_check(nax,...)    % general case (see below)
%
% Input:
% -------
%   nax                     % Number of rebin descriptors that is expected
%
%   One rebin axis:
%     [] or 0               % Leave bins as they are
%     xlo,xhi               % Defines single bin, equivalent to [xlo,xhi] (single axis only)
%     xlo,0,xhi             % Retain existing bin boundaries between xlo and xhi
%     x1,x2,x3,...          % Set of bin boundaries: equivalent to [x1,x2,x3,...]
%
%   Any number of rebin axes:
%     xbins1, xbins2, ...   % Set of bin boundaries, one vector of bin boundaries per dimension,
%                           % each with one of the forms above i.e.
%                           % General form:
%                           %   xbins=[x1,x2,x3,...] where x1<x2<x3... (numel(xbins)>=2)
%                           % Special case:
%                           %   xbins=[] or 0     - leave binning as it currently is
%                           %   xbins=[xlo,0,xhi]
%
% Output:
% -------
%   ok          true if no problems, false if error found in input e.g. not strictly monotonic boundaries
%   xbounds     cell array of rebin descriptor vectors {xbins1, xbins2,...}; [] if ok==false
%              (Note: input of [] or 0 for a dimension is returned as [])
%   any_dx_zero Logical array; an element is true if one or more dx in the corresponding
%              descriptor is zero.
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
        % input is not a single empty argument or a numeric vector, so only valid input is non empty numeric scalars
        xvals=zeros(1,numel(varargin));
        for i=1:numel(varargin)
            if ~isempty(varargin{i}) && isnumeric(varargin{i}) && isscalar(varargin{i})
                xvals(i)=varargin{i};
            else
                ok=false; xbounds=[]; any_dx_zero=false;
                mess='Check bin boundary arguments are a numeric vector or list of scalars';
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
any_dx_zero=false(1,nax);
xbounds=cell(1,nax);
for i=1:nax
    [ok,xbounds{i},any_dx_zero(i),mess]=check_boundaries(varargin{i});
    if ~ok, xbounds=[]; any_dx_zero=false; return, end
end
else
    ok=false; xbounds=[]; any_dx_zero=false;
    mess='Check number of bin boundary vectors matches number of rebin axes';
end

% -------------------------------------------------------------------------------------------------
function [ok,xbounds,any_dx_zero,mess]=check_boundaries(xbounds)
% Check boundaries are OK
if isempty(xbounds)
    ok=true; xbounds=[]; any_dx_zero=true; mess=''; return    % force xbounds to be empty numeric
elseif isnumeric(xbounds)
    if isscalar(xbounds) && xbounds==0
        ok=true; xbounds=[]; any_dx_zero=true; mess=''; return    % force xbounds to be empty numeric
    elseif numel(xbounds)==3 && isvector(xbounds) && xbounds(2)==0
        if xbounds(1)<xbounds(3)
            if size(xbounds,1)>1, xbounds=xbounds'; end     % make row vector
            ok=true; mess=''; any_dx_zero=true;
        else
            ok=false; xbounds=[]; any_dx_zero=false;
            mess='Upper limit must be greater than lower limit in bin boundary vector';
        end
    elseif numel(xbounds)>=2 && isvector(xbounds) && ~any(diff(xbounds)<=0)
        if size(xbounds,1)>1, xbounds=xbounds'; end     % make row vector
        ok=true; mess=''; any_dx_zero=false;
    else
        ok=false; xbounds=[]; any_dx_zero=false;
        mess='Rebin boundaries must be strictly monotonic increasing vector i.e. bin widths all > 0, special cases of ''0'' or empty';
    end
else
    ok=false; xbounds=[]; any_dx_zero=false;
    mess='Rebin boundaries must form numeric vector';
end
