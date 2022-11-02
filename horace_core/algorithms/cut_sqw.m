function varargout = cut_sqw(source, varargin)
%CUT_SQW Take a cut from an SQW object or file.
%
% legacy interface to cut operation on sqw objects or files containing
% such objects or cellarray of such objects
%
% Input:
% ------
% source     An `sqw` object or .sqw file to take a cut from or cellarry of
%            such objects
%
% For more info on arguments see help for sqw/cut.
%

% In cut_sqw we enforce that input must be SQW file or sqw object

if nargout == 1
    varargout{1} = cut(source,'-sqw_only',varargin{:});
else
    if iscell(source) && numel(source)>=nargout
        wout = cut(source(1:nargout),'-sqw_only','-cell',varargin{:});
    else
        wout = cut(source,'-sqw_only','-cell',varargin{:});
    end
    if nargout == 1
        varargout{1} =pack_output_(wout,false);
    else
        for i=1:nargout
            varargout{i} =wout{i};
        end
    end
end

