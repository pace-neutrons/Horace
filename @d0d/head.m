function varargout = head (varargin)
% Display a summary of a d0d object or file containing d0d information.
% 
%   >> head(w)              % Summary for object (or array of objects)
%   >> head(d0d,filename)   % Summary for named file (or array of names)
%
% To return header information in a structure, without displaying to screen:
%
%   >> h=head(...)          % Fetch principal header information
%
%
% The facility to get head information from file(s) is included for completeness, but
% more usually you would use the function:
%   >> head_horace(filename)
%   >> h=head_horace(filename)
%
%
% Input:
% -----
%   w           d0d object or array of d0d objects
%       *OR*
%   d0d         Dummy d0d object to enforce the execution of this method.
%               Can simply create a dummy object with a call to d0d:
%                   e.g. >> w = head(d0d,'c:\temp\my_file.d0d')
%
%   file        File name, or cell array of file names. In latter case, displays
%               summary for each sqw object
%
% Output (optional):
% ------------------
%   h           Structure with header information, or cell array of structures if
%               given a cell array of file names.

% Original author: T.G.Perring
%
% $Revision:: 1750 ($Date:: 2019-04-09 10:04:04 +0100 (Tue, 9 Apr 2019) $)

% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type


% Parse input
% -----------
[w, args, mess] = horace_function_parse_input (nargout,varargin{:},'$obj_and_file_ok');
if ~isempty(mess), error(mess); end

% Perform operations
% ------------------
% Now call sqw cut routine. Output (if any), is a cell array, as method is passed a data source structure
argout=head(sqw,w,args{:});

% Package output arguments
% ------------------------
[varargout,mess]=horace_function_pack_output(w,argout{:});
if ~isempty(mess), error(mess), end
