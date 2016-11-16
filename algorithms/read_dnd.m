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
% $Revision: 877 $ ($Date: 2014-06-10 12:35:28 +0100 (Tue, 10 Jun 2014) $)
%
argi = varargin;
argi{end+1} = '-get_dnd'; %TODO: shame! should be proper OOP

out = read_sqw(argi{:});
if ~iscell(out)
    varargout = {out};
else
    varargout = out;
end

