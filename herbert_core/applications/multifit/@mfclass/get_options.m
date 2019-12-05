function varargout = get_options (obj, varargin)
% Get the value(s) of one or more optional parameters
%
% Display on screen only:
%   >> obj.get_options                      % display all options
%   >> obj.get_options (name)               % display named option
%   >> obj.get_options (name1, name2,...)   % display named options
%
% Return value(s):
%   >> options = obj.get_options            % return all values as a structure
%   >> options = obj.get_options (name)     % return named option value
%   >> options = obj.get_options (name1, name2,...) % return named option values
%                                                   % as a structure
%
% For information about the available options, see the help for the method
% set_options


% Original author: T.G.Perring
%
% $Revision:: 838 ($Date:: 2019-12-05 14:56:03 +0000 (Thu, 5 Dec 2019) $)


options = obj.options_;

if nargin==1
    % Get all
    options_out = options;
else
    % Get named option(s)
    opt_names = fieldnames(options);
    for k=1:numel(varargin)
        tf = strncmpi (varargin{k}, opt_names, numel(varargin{k}));
        if sum(tf)==1
            i = find(tf);
            options_out.(opt_names{i}) = options.(opt_names{i});
        else
            error('Unrecognised or ambiguous option name')
        end
    end
end

% Display or return options
if nargout==0
    disp(options_out)
else
    if numel(varargin)==1
        varargout{1} = options_out.(opt_names{i});
    else
        varargout{1} = options_out;
    end
end

