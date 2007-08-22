function data = get(w)
% GET   Return a structure with the fields of a 1D dataset.
%
% Syntax:
%   >> data = get (w)    % w the class; data is the corresponding structure

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring



for j = 1:numel(w)
    names = fieldnames(w(j));
    for i=1:length(names)
        data(j).(names{i}) = w(j).(names{i});
        if j == 1
            data(1:numel(w)) = data(1);
        end
    end
end