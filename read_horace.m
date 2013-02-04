function varargout = read_horace(varargin)
% Read sqw or d0d/d1d/...d4d object from a file or array of objects from a set of files as appropriate to file contents
% 
%   >> w=read_horace            % prompts for file
%   >> w=read_horace(file)      % read named file or cell array of file names into array

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

[varargout,mess] = horace_function_call_method (nargout, @read, '$hor', varargin{:});
if ~isempty(mess), error(mess), end
