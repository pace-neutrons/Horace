function varargout = read_dnd(varargin)
% Read d0d, d1d, d2d, d3d or d4d object from a file, or an array of objects from a cell array of file names
%
%   >> w=read_dnd           % prompts for file
%   >> w=read_dnd(file)     % read named file or cell array of file names into array
%
% If data is sqw-type i.e. has pixel information, this is ignored and is treated as equivalent
% d0d, d1d,...d4d object.

% Original author: T.G.Perring
%
% $Revision:: 1758 ($Date:: 2019-12-16 18:18:50 +0000 (Mon, 16 Dec 2019) $)
%
argi = varargin;
argi{end+1} = '-get_dnd';
if nargout == 0
    read_horace(argi{:});    
else
    varargout = read_horace(argi{:});
    if ~iscell(varargout)
        varargout = {varargout};
    end
end


