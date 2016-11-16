function varargout = read_horace(varargin)
% Read sqw or d0d/d1d/...d4d object from a file or array of objects from a set of files as appropriate to file contents
% 
%   >> w=read_horace            % prompts for file
%   >> w=read_horace(file)      % read named file or cell array of file names into array

% Original author: T.G.Perring
%
% $Revision: 877 $ ($Date: 2014-06-10 12:35:28 +0100 (Tue, 10 Jun 2014) $)

if nargout == 0
    read_sqw(varargin{:});    
else
    varargout = read_sqw(varargin{:});
    if ~iscell(varargout)
        varargout = {varargout};
    end
end
