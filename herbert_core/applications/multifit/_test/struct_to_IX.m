function wout = struct_to_IX (w)
% Convert structure array to IX_dataset_1d array
%
%   >> wout = struct_to_IX (w)
%
% Utility function for testing mfclass

wout = repmat(IX_dataset_1d, size(w));
for i=1:numel(w)
    wout(i) = IX_dataset_1d(w(i).x, w(i).y, w(i).e, ['Workspace ',num2str(i)],'x_axis','y_axis');
end
