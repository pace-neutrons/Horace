function wout=transpose(win)
% Swap the x and y axes for an IX_dataset-2d or array of IX_dataset_2d
%
%   >> wout=transpose(win)

wout=repmat(IX_dataset_2d,size(win));   % preallocate
for iw=1:numel(win)
    wout(iw)=IX_dataset_2d(win(iw).title, win(iw).signal', win(iw).error', win(iw).s_axis,...
        win(iw).y, win(iw).y_axis, win(iw).y_distribution,...
        win(iw).x, win(iw).x_axis, win(iw).x_distribution);
end
