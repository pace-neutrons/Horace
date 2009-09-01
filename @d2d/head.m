function varargout = head(varargin)
% Read header of a d2d object stored in a file
% 
%   >> w=head(d2d,file)
%
% Need to give first argument as a d2d object to enforce the execution of this method.
% Can simply create a dummy object with a call to sqw:
%    e.g. >> read(d2d,'c:\temp\my_file.sqw')
% Gives the same information as display for an sqw object

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

if nargout==0
    head(sqw(varargin{1}),varargin{2:end});  % will have at least one argument in varargin, or matlab would never have selected this method
else
    h=head(sqw(varargin{1}),varargin{2:end});
    % Package output: if file data source then package all output arguments as a single cell array, as the output
    % will be unpacked by control routine that called this method. If object data source, then package as conventional varargout
    % In this case, there is at most only one output argument
    [data_source, args, source_is_file] = parse_data_source (sqw(varargin{1}), varargin{2:end});
    if source_is_file
        varargout{1}=h;    % must be cell array
    else
        varargout{1}=h;
    end
end
