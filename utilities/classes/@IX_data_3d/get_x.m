function x=get_x(w,iax)
% Get the x-axis for a IX_dataset_3d
%
%   >> x=getx(w)        % cell array of row vectors, one per axis
%   >> x=getx(w,iax)    % iax=1,2 or 3; row vector for indicated axis

if numel(w)==1
    if nargin==1
        x = w.xyz_';
    elseif nargin==2
        if isscalar(iax)
            if iax==1
                x=w.xyz_{1};
            elseif iax==2
                x=w.xyz_{2};
            elseif iax==3
                x=w.xyz_{3};
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
