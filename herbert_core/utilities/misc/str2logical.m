function tf = str2logical(str)

% Parses a string to a logical
%
% This string can be a single or multiple
% (space-separated) string of integers or "true" or "false" strings.
% Anything which is not an integer, "true" or "false" is considered false.
%
% Example:
% >> str2logical("true")
% ans =
%       logical
%       1
% >> str2logical("true 1 10 false 0 -1 1.2")
% ans =
%       7x1 logical array
%       1 1 1 0 0 0 0


str = split(str);
tf = cellfun(@str2logical_, str);

end

function tf = str2logical_(str)

switch lower(str)
  case 'true'
    tf = true;
  case 'false'
    tf = false;
  otherwise
    match = regexp(str, '^[0-9]+$', 'match');
    if ~isempty(match)
        tf = logical(str2num(match{1}));
    else
        tf = false;
    end
end

end
