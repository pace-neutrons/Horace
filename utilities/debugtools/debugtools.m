function debugtools(varargin)
% Useful tools to help debug or run tests
%
% This utility allows a line that calls a function to exist in code but
% which only calls that function if debugtools is turned on.
%
% Outside the code being tested:
%   >> debugtools ('on')    % turn debug tests on
%   >> debugtools ('off')   % turn debug tests off
%
% In the code being tested, have the line
%           :
%       debugtools (funchandle, arg1, arg2, ...)
%           :
%
%   This will run the function with the given function handle and which will
%   be called with arguments arg1, arg2,...
%   Note: there can be no return arguments from the function.

persistent debugtools_status

if isempty(debugtools_status)
    debugtools_status = false;
end

if nargin==1 && ~isempty(varargin{1}) && is_string(varargin{1})
    % Setting debugtools on or off
    if strcmpi(varargin{1},'on')
        debugtools_status = true;
    elseif strcmpi(varargin{1},'off')
        debugtools_status = false;
    else
        error('Debugtools:UnrecognisedArgument''Unrecognised argument to debugtools')
    end
    
elseif debugtools_status && nargin>=1
    % debugtools are on and there is at least one argument
    if isa(varargin{1},'function_handle')
        funchandle = varargin{1};
        funchandle(varargin{2:end})
    else
        error('Debugtools:UnrecognisedArgument''Unrecognised argument(s) to debugtools')
    end
end
