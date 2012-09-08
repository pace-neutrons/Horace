function wout = deriv_z (w)
% Calculate numerical first derivative along the z-axis of an IX_dataset_3d or array of IX_datasset_2d
%
%   >> wd = deriv_y (w)
%
% Input:
% ------
%   w   input IX_dataset_3d or array of IX_dataset_3d
%
% Output:
% -------
%   wd  output IX_dataset_3d or array of IX_dataset_3d

wout=w;
for i=1:numel(w)
    if numel(w(i).signal)>0    % if empty data, dont do anything
        if ishistogram(w(i),3)
            zc=0.5*(w(i).z(1:end-1)+w(i).z(2:end));
            [wout(i).signal,wout(i).error]=deriv_xye_n(3,zc,w(i).signal,w(i).error);
        else
            [wout(i).signal,wout(i).error]=deriv_xye_n(3,w(i).z,w(i).signal,w(i).error);
        end
    end
end
