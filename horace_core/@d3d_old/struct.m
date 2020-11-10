function public_struct = struct(this)
% A Comprehensive Guide to Object Oriented Programming in MATLAB
%   Chapter 9 example struct
%   (c) 2004 Andy Register

% Generic method

names = fieldnames(this);  % tailored version returns public names
values = cell(length(names), length(this(:)));  % preallocate
for k = 1:length(names)
    [values{k, :}] = subsref(this(:), substruct('.', names{k}));
end
public_struct = reshape(cell2struct(values, names, 1), size(this));