function varargout = cut (varargin)
% Take a cut from a d4d object by integrating over one or more of the plot axes.
% 
% Syntax:
%  make cut:
%   >> w = cut (data_source, p1_bin, p2_bin, p3_bin, p4_bin)
%
%   >> w = cut (..., '-save')       % Save cut to file (prompt for output file)
%   >> w = cut (...,  filename)     % save cut to named file
%
%   >> cut(...)                     % save cut to file without making output to workspace 
% 
% Input:
% ------
%   data_source     Data source: sqw file name or d4d-type data structure
%
%   p1_bin          Binning along first plot axis
%   p2_bin          Binning along second plot axis
%   p3_bin          Binning along third plot axis
%   p4_bin          Binning along fourth plot axis
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
%   w              Output data object (d0d, d1d,...d4d depending on binning requirements)


% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)


% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

if nargout==0
    cut(sqw(varargin{1}),varargin{2:end});  % will have at least one argument in varargin, or matlab would never have selected this method
else
    wout=cut(sqw(varargin{1}),varargin{2:end});
    % Package output: if file data source then package all output arguments as a single cell array, as the output
    % will be unpacked by control routine that called this method. If object data source, then package as conventional varargout
    % In this case, there is at most only one output argument
    [data_source, args, source_is_file] = parse_data_source (sqw(varargin{1}), varargin{2:end});
    if source_is_file
        varargout{1}={dnd(wout{1})};    % must ensure output is still a cell array after conversion to dnd
    else
        varargout{1}=dnd(wout);
    end
end
