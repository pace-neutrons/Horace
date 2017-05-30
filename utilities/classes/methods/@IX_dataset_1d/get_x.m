function x=get_x(w,iax)
% Get the x-axis for a IX_dataset_1d
%
%   >> x=getx(w)        % x is a cell array, one element equal to x axis
%   >> x=getx(w,iax)    % iax=1 only; result is row vector of x axis values
%
% The syntax is to be consistent with getx for IX_dataset_2d, IX_dataset_3d

if numel(w)==1
    if nargin==1
        x={w.x};  
    elseif nargin==2
        if isscalar(iax)
            if iax==1
                x=w.x;
            else
                error('Check axis index')
            end
        else
            error('Axis index must be scalar')
        end
    end 
else
    error('Can only have scalar input dataset')
end
