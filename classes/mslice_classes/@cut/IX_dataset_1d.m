function wout = IX_dataset_1d (cut)
% Convert cut object into a IX_dataset_1d
%
%   >> wout=IX_dataset_1d(cut)
%
%   cut     Cut object, or array of cut objects
%
%   wout    IX_dataset_1d object, or array of objects. Will be point data.

wout=repmat(IX_dataset_1d, size(cut));
for i=1:numel(cut)
    % set title:
    if ~isempty(cut(i).CutDir)||~isempty(cut(i).CutFile)  % there is a cut file name
        temp = cellstr(cut(i).title);   % add file name to top of the title
        ltemp = length(temp);
        ltitle = ltemp + 1;
        title{1} = avoidtex(fullfile(cut(i).CutDir,cut(i).CutFile));
        title(2:ltitle) = temp(1:ltemp);
    else
        title=cellstr(cut(i).title);
    end
    
    s_axis = IX_axis (cut(i).y_label);
    x_axis = IX_axis (cut(i).x_label);
    wout = IX_dataset_1d (title, cut(i).y, cut(i).e, s_axis, cut(i).x, x_axis, false);
end
