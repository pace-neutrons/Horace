function warnonce(id, message, varargin)
%%warnonce Warn only once ignoring subsequent calls
% Inputs:
% -------
% id      -- Warning identifier as per `warning`
% message -- Warning message as per `warning`

% evalc evaluates this variable in different workspace, so this variable is
% workspace specific!!!
persistent idset

clear = strcmp(id, 'clear');

if isempty(idset) || (clear && ~exist('message', 'var'))
    idset = {};
elseif clear
    idset(ismember(idset, message)) = '';
end

if clear
    return
end

% N.B. let "warning"/"sprintf" handle invalid args
message = sprintf(message, varargin{:});

if ~ismember(id, idset)
    warning(id, message);
    idset{end+1} = id;
else
    lastwarn(message, id);
end

end
