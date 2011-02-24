function varargout = cut (varargin)
% Take a cut from a d1d object or array of objects by integrating over one or more of the plot axes.
% 
% Syntax:
%  make cut:
%   >> w = cut (data_source, p1_bin, p2_bin)
%
%   >> w = cut (..., '-save')       % Save cut to file (prompt for output file)
%   >> w = cut (...,  filename)     % save cut to named file
%
%   >> cut(...)                     % save cut to file without making output to workspace 
% 
% Input:
% ------
%   data_source     Data source: sqw file name or d1d-type data structure
%
%   p1_bin          Binning along first plot axis
%   p2_bin          Binning along second plot axis
%                           
%                   For each binning entry:
%               - [] or ''          Plot axis: use bin boundaries of input data
%               - [pstep]           Plot axis: sets step size; plot limits taken from extent of the data
%                                   If pstep=0 then use current bin size and synchronise
%                                  the output bin boundaries with the current boundaries. The overall range is
%                                  chosen to ensure that the range of the input data is contained within
%                                  the bin boundaries.
%               - [plo, phi]        Integration axis: range of integration - those bin centres that lie inside this range 
%                                  are included.
%               - [plo, pstep, phi] Plot axis: minimum and maximum bin centres and step size
%                                   If pstep=0 then use current bin size and synchronise
%                                  the output bin boundaries with the current boundaries. The overall range is
%                                  chosen to ensure that the range plo to phi is contained within
%                                  the bin boundaries.
%
% Output:
% -------
%   w              Output data object (d0d, d1d, d2d depending on binning requirements)


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

% If data source is a filename or data_source structure, then must ensure that matches dnd type
[data_source, args, source_is_file, sqw_type, ndims, source_arg_is_filename, mess] = parse_data_source (sqw(varargin{1}), varargin{2:end});
if ~isempty(mess)
    error(mess)
end
if source_is_file   % either file names or data_source structure as input
    if any(sqw_type) || any(ndims~=dimensions(varargin{1}(1)))     % must all be the required dnd type
        error(['Data file(s) not (all) ',classname,' type i.e. no pixel information'])
    end
end


% Perform cuts
% ------------
% Now call sqw cut routine
if nargout==0
    if source_is_file
        cut(sqw,data_source,args{:});
    else
        cut(sqw(data_source),args{:});
    end
else
    if source_is_file
        argout=cut(sqw,data_source,args{:});   % output is a cell array
    else
        argout=cut(sqw(data_source),args{:});
    end
end

% Package output: if file data source structure then package all output arguments as a single cell array, as the output
% will be unpacked by control routine that called this method. If object data source or file name, then package as conventional
% varargout

% In this case, there is only one output argument
if nargout>0
    if source_is_file && ~source_arg_is_filename
        varargout{1}={dnd(argout{1})};    % must ensure output is still a cell array after conversion to dnd
    else
        varargout{1}=dnd(argout);
    end
end
