function [ok,xbounds,mess]=rebin_boundaries_check(varargin)
% Check that the rebin boundaries are valid
%
% Input is one vector of bin boundaries per dimension

% -------------------------------------------------------------------------------------------------
% xlo,xhi  - only valid if a single rebin axis
if numel(varargin)==2 && isnumeric(varargin{1}) && isnumeric(varargin{2}) &&...
        isscalar(varargin{1})  && isscalar(varargin{2})
    if varargin{2}>varargin{1}
        ok=true;
        xbounds={[varargin{1},varargin{2}]};
        mess='';
    else
        ok=false; xbounds=[];
        mess='Upper limit must be greater than lower limit';
    end
    
% -------------------------------------------------------------------------------------------------
% one or more vectors
else
    xbounds=cell(1,numel(varargin));
    for i=1:numel(varargin)
        if isnumeric(varargin{i}) && (size(varargin{i},1)==1 || size(varargin{i},2))
            if numel(varargin{i})>=2 && ~any(diff(varargin{i})<=0)
                if size(varargin{i},1)==1
                    xbounds{i}=varargin{i};
                else
                    xbounds{i}=varargin{i}';
                end
            else
                ok=false; xbounds=[];
                mess='Rebin boundaries must be strictly monotonic increasing i.e. bin widths all > 0';
                return
            end
        else
            ok=false; xbounds=[];
            mess='Boundaries must form numeric vector';
            return
        end
    end
    ok=true;
    mess='';
end
