function varargout = read_sqw(varargin)
% Read sqw from a file or array of objects from a set of files as appropriate to file contents
% 
%   >> w=read_horace            % prompts for file
%   >> w=read_horace(file)      % read named file or cell array of file names into array

% Original author: T.G.Perring
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)

argi = varargin;
argi{end+1} = '-force_sqw';

if nargout == 0
    read_horace(argi{:});    
else
    varargout = read_horace(argi{:});
    if ~iscell(varargout)
        varargout = {varargout};
    end
end
