function C = struct_to_named_args_cell(S)
%STRUCT_TO_NAMED_ARGS_CELL Convert structure containing name-value pairs to
% cell array
%
% C = struct_to_named_args_cell(S) converts a scalar structure array containing
% name-value pairs to a cell array containing the names and values.
% This function converts a 1-by-1 structure with n number of fields to a
% 1-by-2n cell array with interleaved names and values.
%
% This function aims to be equivalent to namedargs2cell, which is a Matlab
% built-in introduced in R2019b. namedargs2cell is called if it's available,
% otherwise code that aims to replicate namedargs2cell's behaviour is executed.
%
% Input:
% ------
% S    A scalar struct.
%
% Output:
% -------
% C    A cell array containing names and values of S.
%
% Example:
% --------
%   >> clear s, s.category = 'tree'; s.height = 37.4; s.name = 'birch';
%   >> c = struct_to_named_args_cell(s)
%   c =
%     1x6 cell array
%       {'category', 'tree', 'height', 37.4000, 'name', 'birch'}
%
try
    % namedargs2cell introduced in R2019b
    C = namedargs2cell(S);
    return
catch ME
    if ~strcmp(ME.identifier, 'MATLAB:UndefinedFunction')
        rethrow(ME);
    end
end

field_names = fieldnames(S);
C = cell(1, 2*numel(field_names));
for i = 1:numel(field_names)
    field_name = field_names{i};
    C{2*i - 1} = field_name;
    C{2*i} = S.(field_name);
end
