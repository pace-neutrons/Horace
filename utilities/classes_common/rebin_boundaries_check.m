function [ok,xbounds,mess]=rebin_boundaries_check(varargin)
% Check that the rebin boundaries are valid
%
% Input is one vector of bin boundaries per dimension

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
