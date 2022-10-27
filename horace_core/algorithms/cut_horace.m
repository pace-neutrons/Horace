function varargout = cut_horace(source,varargin)
% Take a cut from a file or files containing sqw, or d0d,d1d...or d4d data
%
% legacy interface to cut operation on dnd-type objects or files containing
% such objects or cellarray of such objects
%
%   >> wout=cut_horace (file, arg1, arg2, ...)
%
% If the data in the file(s) is sqw-type i.e. has pixel information, the
% data will be passed to the corresponding sqw cut method. If the data is
% dnd type i.e. there is no pixel information, then the method for the
% appropriate d0d, d1d,...d4d object is called
%
% For full details of arguments for the cut method, see the help for the
% corresponding data type:
%
%   >> help sqw/cut             % cut for sqw object
%   >> help d1d/cut             % cut for d1d object
%   >> help d2d/cut             % cut for d2d object
%          :
%
%
% See also: cut_sqw, cut_dnd


% Original author: T.G.Perring
%
if nargout == 1
    varargout{1} = cut(source,varargin{:});
else
    if iscell(source) && numel(source)>=nargout
        wout = cut(source(1:nargout),'-cell',varargin{:});
    else
        wout = cut(source,'-cell',varargin{:});
    end
    if nargout == 1
        varargout{1} =pack_output_(wout,false);
    else
        for i=1:nargout
            varargout{i} =wout{i};
        end
    end
end


