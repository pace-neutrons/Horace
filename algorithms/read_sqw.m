function varargout = read_sqw(varargin)
% Read sqw from a file or array of objects from a set of files as appropriate to file contents
% 
%   >> w=read_horace            % prompts for file
%   >> w=read_horace(file)      % read named file or cell array of file names into array

% Original author: T.G.Perring
%
% $Revision:: 1751 ($Date:: 2019-06-03 09:47:49 +0100 (Mon, 3 Jun 2019) $)

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
