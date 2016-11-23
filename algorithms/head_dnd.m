function varargout=head_dnd(varargin)
% Display a summary of a file or set of files containing dnd-type information
% 
%   >> head_sqw          % Prompts for file and display summary of contents
%   >> head_sqw (file)   % Display summary for named file or for cell array of file names
%
% To return header information in a structure, without displaying to screen:
%
%   >> h = head_dnd
%   >> h = head_dnd (file)           % Fetch principal header information
%
%
% Input:
% -----
%   file        File name, or cell array of file names. In latter case, displays
%               summary for each sqw object
%
% Output (optional):
% ------------------
%   h           Structure with header information, or cell array of structures if
%               given a cell array of file names.

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

if nargout>0
    varargout = head_horace(varargin{:});
    if ~iscell(varargout)
        varargout = {varargout};
    end
else
     head_horace(varargin{:});
end
