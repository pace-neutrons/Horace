function wout = deriv (w)
% Calculate numerical first derivative along the x-axis of an IX_dataset_3d or array of IX_datasset_2d
%
%   >> wd = deriv (w)
%
% Input:
% ------
%   w   input IX_dataset_3d or array of IX_dataset_3d
%
% Output:
% -------
%   wd  output IX_dataset_3d or array of IX_dataset_3d

% Identical to deriv_x

wout=w;
for i=1:numel(w)
    if numel(w(i).signal)>0    % if empty data, dont do anything
        if ishistogram(w(i),1)
            xc=0.5*(w(i).x(1:end-1)+w(i).x(2:end));
            [wout(i).signal,wout(i).error]=deriv_xye_n(1,xc,w(i).signal_,w(i).error_);
        else
            [wout(i).signal,wout(i).error]=deriv_xye_n(1,w(i).xyz_{1},w(i).signal_,w(i).error_);
        end
    end
end
