function w = cut_sqw(varargin)
% Take a cut from a file containing sqw object
%
% Syntax:
%   >> w=cut_sqw (file, arg1, arg2, ...)    % sqw data in named file, or cell array of filenames
%                                           % Output is an array if given cell array of files
%
% For full details of arguments for cut method, type:
%
%   >> help sqw/cut             % cut for sqw objects

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

% Catch case of sqw object
if nargin>=1 && isa(varargin{1},'sqw')
    if nargout==0
        cut(varargin{:});
    else
        w=cut(varargin{:});
    end
    return
end

% Check file name(s), prompting if necessary
if nargin==0
    error('Must give file name or cell array of filenames of sqw object(s)')
else
    [file_internal,mess]=getfile_horace(varargin{1});
end
if ~isempty(mess)
    error(mess)
end

% Make object
if nargout==0
    function_sqw(file_internal,@cut,varargin{2:end});
else
    w=function_sqw(file_internal,@cut,varargin{2:end});
end
