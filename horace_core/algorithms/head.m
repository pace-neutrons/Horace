function varargout = head (varargin)
% Display a summary of an sqw object or file containing sqw information.
%
%   >> head(w)          % Display summary for object (or array of objects)
%   >> head(filename)   % Display summary for named file (or array of names)
%
% To return header information in a structure, without displaying to screen:
%
%   >> h=head(...)          % Fetch principal data information
%   >> h=head(...,'-full')  % Fetch full data information
%
%
% The facility to get head information from file(s) is included for completeness, but
% more usually you would use the function:
%   >> head_horace(filename)
%   >> h=head_horace(filename)
%   >> h=head_horace(filename,'-full')
%
%
% Input:
% -----
%   w           sqw object or array of sqw objects
%       *OR*
%   sqw         Dummy sqw object to enforce the execution of this method.
%               Can simply create a dummy object with a call to sqw:
%                   e.g. >> w = head('c:\temp\my_file.sqw')
%
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


% Parse input
% -----------
if iscell(varargin{1})
    argi = [varargin{1},varargin(2:end)];
else
    argi  = varargin;
end

valid = cellfun(@(x)(ischar(x)||isstring(x)),argi);
if ~any(valid) %TODO: allow sqw objects to be provided among with filenames
    error('HORACE:head:invalid_argument',...
        'algorithm "head" accepts only array of strings describing filenames and options as input. Some input are not string or char type');
end

if nargout == 0
    head_horace(argi{:});
else
    vout = head_horace(argi{:});
    if ~iscell(vout)
        varargout = {vout};
    else
        if nargout > 1
            varargout = vout{1}(1:nargout);
        else
            varargout = vout;
        end
    end
end
