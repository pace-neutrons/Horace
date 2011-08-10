function [ok,xbounds,mess]=integrate_ranges_check(varargin)
% Check that the integration ranges are valid
%
% Input
% ------
%   x1_lo, x1_hi, x2_lo, x2_hi, ...
%   [x1_lo, x1_hi, x2_lo, x2_hi, ...]
%   [x1_lo, x1_hi], [x2_lo, x2_hi], ...
%
%
% Output
% ------
%   {[x1_lo, x1_hi], [x2_lo, x2_hi], ...}

% Parse input
if numel(varargin)==0
    ok=false; xbounds=[];
    mess='No integration ranges provided';
    return
else
    all_scalar=true;
    for i=1:numel(varargin)
        if ~isscalar(varargin{i})
            all_scalar=false;
            break
        end
    end
    
    if all_scalar
        % x1_lo, x1_hi, x2_lo, x2_hi, ...
        if rem(numel(varargin),2)==0
            xbounds=cell(1,numel(varargin)/2);
            for i=1:numel(varargin)/2
                if isnumeric(varargin{2*i-1}) && isnumeric(varargin{2*i})
                    xbounds{i}=[varargin{2*i-1},varargin{2*i}];
                else
                    ok=false; xbounds=[];
                    mess='Check integration ranges are all numeric';
                    return
                end
            end
        else
            ok=false; xbounds=[];
            mess='Check number of integration limits is even';
            return
        end
        
    elseif numel(varargin)==1 && isnumeric(varargin{i})
        % [x1_lo, x1_hi, x2_lo, x2_hi, ...]
        if rem(numel(varargin{1}),2)==0
            ndim=numel(varargin{1})/2;
            xbounds=mat2cell(reshape(varargin{1},2,ndim)',ones(1,ndim),2)';
        else
            ok=false; xbounds=[];
            mess='Check number of integration limits is even';
            return
        end
        
    else
        % [x1_lo, x1_hi], [x2_lo, x2_hi], ...
        xbounds=cell(1,numel(varargin));
        for i=1:numel(varargin)
            if isnumeric(varargin{i}) && numel(varargin{i})==2
                if size(varargin{i},1)==1
                    xbounds{i}=varargin{i};
                else
                    xbounds{i}=varargin{i}';
                end
            else
                ok=false; xbounds=[];
                mess='Check integration ranges are all numeric scalars or pairs';
                return
            end
        end
    end
    
end

% Check the limits
for i=1:numel(xbounds)
    if diff(xbounds{i})<=0
        ok=false; xbounds=[];
        mess='Check integration ranges are all have xlo < xhi';
        return
    end
end
ok=true;
mess='';
