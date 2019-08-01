function varargout = debugtools(varargin)
% Useful tools to help debug or run tests
%
% This utility allows a line that calls a function to exist in code but
% which only calls that function if debugtools is turned on.
%
% Outside the code being tested:
%   >> debugtools ('on')        % turn debug tests on
%   >> debugtools ('off')       % turn debug tests off
%
%   >> stauts_on = debugtools   % query present status
%
% In the code being tested, have the line
%           :
%      debugtools (funchandle, arg1, arg2, ...)
%           :
%
%   This will run the function with the given function handle and which will
%   be called with arguments arg1, arg2,...
%   Note: there can be no return arguments from the function.

persistent debugtools_status

if isempty(debugtools_status)
    debugtools_status = false;
end

if debugtools_status && nargin>=1 && isa(varargin{1},'function_handle')
    funchandle = varargin{1};
    funchandle(varargin{2:end});
    
elseif nargin==1 && ~isempty(varargin{1}) && is_string(varargin{1})
    % Setting debugtools on or off
    if strcmpi(varargin{1},'on')
        debugtools_status = true;
        if nargout>0, varargout{1} = debugtools_status; end
    elseif strcmpi(varargin{1},'off')
        debugtools_status = false;
        if nargout>0, varargout{1} = debugtools_status; end
    else
        error('Debugtools:UnrecognisedArgument''Unrecognised argument to debugtools')
    end
    
elseif nargin==0
    if nargout>0
        varargout{1} = debugtools_status;
    else
        if debugtools_status
            disp('Debugtools status: on')
        else
            disp('Debugtools status: off')
        end
    end
    
else
    error('Debugtools:UnrecognisedArgument''Unrecognised argument(s) to debugtools')
end
