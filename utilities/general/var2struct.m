function S = var2struct (varargin)
% Create a structure from a list of input arguments
%
%   >> S = var2struct (a, b, c, ...)
%
% The structure has fields with names the same as those of the variables,
% and values equal to the variables
%
% e.g.
%   >> S = var2struct (filename, arr2D, is_chiral)
%   S = 
%     struct with fields:
% 
%          filename: 'data.txt'
%             arr2D: [500×500 double]
%         is_chiral: 0
%
% Input:
% ------
%   a, b, c,... Variables to added to structure
%
% Output:
% -------
%   S           Structure with fields with names the same as those of the
%              variables, and values equal to the variables. If an argument
%              is passed for which the name of the variable in the calling
%              worksapce cannot be enquired (e.g. the argument is a constant
%              or an expression), then the name is input_n, where n is the
%              position of the unnamed argument in the input list

S = struct();
for i=1:numel(varargin)
    name = inputname(i);
    if isempty(name)
        name = ['input_',num2str(i)];
    end
    S.(name) = varargin{i};
end
