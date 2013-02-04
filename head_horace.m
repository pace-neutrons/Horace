function varargout=head_horace(varargin)
% Display a summary of a file or set of files containing sqw information
% 
%   >> head_horace          % Prompts for file
%   >> head_horace (file)   % Summary for named file or for cell array of file names
%
% To return header information in a structure, without displaying to screen:
%
%   >> h = head_horace
%   >> h = head_horace (file)           % Fetch principal header information
%   >> h = head_horace (file,'-full')   % Fetch full header information
%
%
% Input:
% -----
%   file        File name, or cell array of file names. In latter case, displays
%               summary for each sqw object
%
% Optional keyword:
%   '-full'     Keyword option; if sqw type data in file, then returns all header and the
%              detecetor information. In fact, it returns the full data structure
%              except for the signal, error and pixel arrays.
%
% Output (optional):
% ------------------
%   h           Structure with header information, or cell array of structures if
%               given a cell array of file names.

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

[varargout,mess] = horace_function_call_method (nargout, @head, '$hor', varargin{:});
if ~isempty(mess), error(mess), end
