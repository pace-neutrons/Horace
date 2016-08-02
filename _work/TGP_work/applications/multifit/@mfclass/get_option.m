function varargout = get_option (obj, opt_name)
% Get the value(s) of one or more optional parameters
%
% Display on screen only:
%   >> obj.get_option           % display all options
%   >> obj.get_option (name)    % display named option
%
% Return value(s):
%   >> obj.get_option           % return all values as a structure
%   >> obj.get_option (name)    % return named option value


options = obj.options_;

if nargin==1
    % Get all
    if nargout==0
        disp(options)
    else
        varargout{1} = options;
    end
else
    % Get named option
    opt_names = fieldnames(options);
    tf = strncmpi (opt_name, opt_names, numel(opt_name));
    if sum(tf)==1
        i = find(tf);
        if nargout==0
            disp(options.(opt_names{i}))
        else
            varargout{1} = options.(opt_names{i});
        end
    else
        error('Unrecognised or ambiguous option name')
    end
end
