function varargout=head_sqw(varargin)
% Display a summary of a file or set of files containing sqw information
%
%   >> head_sqw          % Prompts for file and display summary of contents
%   >> head_sqw (file)   % Display summary for named file or for cell array of file names
%
% To return header information in a structure, without displaying to screen:
%
%   >> h = head_sqw
%   >> h = head_sqw (file)           % Fetch principal header information
%   >> h = head_sqw (file,'-full')   % Fetch full header information
%
%
% Input:
% -----
%   file        File name, or cell array of file names. In latter case, displays
%               summary for each sqw object
%
% Optional keyword:
%   '-full'     Keyword option; if present, then returns all header and the
%              detector information. In fact, it returns the full data structure
%              except for the signal, error and pixel arrays.
%
% Output (optional):
% ------------------
%   h           Structure with header information, or cell array of structures if
%               given a cell array of file names.

% Original author: T.G.Perring
%
% $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)

if nargout>0
    varargout = head_horace(varargin{:});
    if ~iscell(varargout)
        varargout = {varargout};
    end
    
else
    head_horace(varargin{:});
end

