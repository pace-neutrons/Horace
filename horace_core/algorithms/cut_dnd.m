function varargout = cut_dnd(source,varargin)
% legacy interface to cut operation on dnd-type objects or files containing
% such objects or cellarray of such objects
%
% Take a cut from a dnd object or file containing d0d,d1d...or d4d data
%
%   >> w=cut_dnd (file, arg1, arg2, ...)
%
% If the data in the file(s) is sqw-type i.e. has pixel information, the
% pixel information is ignored and the data is treated as the equivalent
% d0d, d1d,...d4d object.
%
% For full details of arguments for the cut method, see the help for the
% corresponding data type:
%
%   >> help d1d/cut             % cut for d1d object
%   >> help d2d/cut             % cut for d2d object
%          :
%
%
% See also: cut, cut_sqw, cut_horace


if nargout == 1
    varargout{1} = cut(source,'-dnd_only',varargin{:});
else
    if iscell(source) && numel(source)>=nargout
        wout = cut(source(1:nargout),'-dnd_only','-cell',varargin{:});
    else
        wout = cut(source,'-dnd_only','-cell',varargin{:});
    end
    if nargout == 1
       varargout{1} =pack_output_(wout,false);        
    else
        for i=1:nargout
            varargout{i} =wout{i};
        end
    end
end

