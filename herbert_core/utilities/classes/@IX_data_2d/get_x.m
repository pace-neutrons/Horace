function x=get_x(w,iax)
% Get the x-axis for a IX_dataset_2d
%
%   >> x=getx(w)        % cell array of row vectors, one per axis
%   >> x=getx(w,iax)    % iax=1 or 2; row vector for indicated axis

if numel(w)==1
    if nargin==1
        x=cell(1,2);
        x{1}=w.x;  
        x{2}=w.y;
    elseif nargin==2
        if isscalar(iax)
            if iax==1
                x=w.x;
            elseif iax==2
                x=w.y;
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
