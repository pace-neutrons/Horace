function varargout = read_sqw(varargin)
% Read sqw from a file or array of objects from a set of files as appropriate to file contents
% 
%   >> w=read_horace            % prompts for file
%   >> w=read_horace(file)      % read named file or cell array of file names into array

% Original author: T.G.Perring
%
% $Revision: 877 $ ($Date: 2014-06-10 12:35:28 +0100 (Tue, 10 Jun 2014) $)

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
