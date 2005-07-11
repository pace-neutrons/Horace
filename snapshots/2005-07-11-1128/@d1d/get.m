function data = get(w)
% GET   Return a structure with the fields of a 1D dataset. For a description
%       the fields, type >> help d1d
%
% Syntax:
%   >> data = get (w)    % w the class; data is the corresponding structure

names = fieldnames(w);
for i=1:length(names)
    data.(names{i}) = w.(names{i});
end
