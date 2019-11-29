function [w2,w1,S] = ISIS_Baseline2016_moderator_to_IX (S)
% Get moderator profile as IX_dataset_2d and 1D:
%
%   >> [w2,w1] = ISIS_Baseline2016_moderator_to_IX (source)
%
% Input:
% ------
%   source      Moderator file (.mat file), or structure as loaded from
%               a moderator .mat file by the function ISIS_Baseline2016_moderator_load
%
% Output:
% -------
%   w2          IX_dataset_2d as a function of time (microseconds) and
%               energy (meV)
%
%   w1          Array of IX_datset_1d, each a function of time (microseconds)
%               and one element of the array for each energy
%
%   S           


if ischar(S)
    S = ISIS_Baseline2016_moderator_load (S);
end

w2 = IX_dataset_2d (S.t, S.en, S.intensity);
w2.title = 'Moderator profile';
w2.x_axis = 'Time (micrseconds)';
w2.y_axis = 'Energy (meV)';
w2.s_axis = 'Intensity per microsecond per meV';

w1 = IX_dataset_1d;
w1.x_axis = 'Time (micrseconds)';
w1.s_axis = 'Intensity per microsecond per meV';
w1 = repmat(w1, [1,size(S.intensity,2)]);
for i=1:numel(w1)
    w1(i) = IX_dataset_1d(S.t, S.intensity(:,i));
    w1(i).title = ['Energy = ',num2str(S.encent(i))];
end

