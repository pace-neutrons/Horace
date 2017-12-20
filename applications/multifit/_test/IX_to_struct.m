function wout = IX_to_struct (w)
% Convert IX_dataset_1d array into a structure array
%
%   >> wout = IX_to_struct (w)
%
% Utility function for testing mfclass

wout = repmat(struct('x',[],'y',[],'e',[]), size(w));
for i=1:numel(w)
    wout(i) = struct('x', w(i).x(:), 'y', w(i).signal(:), 'e', w(i).error(:));
end
