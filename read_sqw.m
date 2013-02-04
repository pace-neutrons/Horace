function varargout = read_sqw(varargin)
% Read sqw object from named file or an array of sqw objects from a cell array of file names
% 
%   >> w=read_sqw           % prompts for file
%   >> w=read_sqw(file)     % read named file or cell array of file names into array

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

[varargout,mess] = horace_function_call_method (nargout, @read, '$sqw', varargin{:});
if ~isempty(mess), error(mess), end
