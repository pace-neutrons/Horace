function [file_full,ok,mess]=putfilecheck(varargin)
% Utility routine that prompts for a file if its name is not given, or it doesn't exist
%
% Check file exists, resolving file name if form pathname:::file where pathname is a globalpath
%   >> [file_full,ok,mess] = putfilecheck (file)    
%
% Or
%   >> [file_full,ok,mess] = putfilecheck                     % prompt for file
%   >> [file_full,ok,mess] = putfilecheck (filterspec)        % prompt with filter
%   >> [file_full,ok,mess] = putfilecheck (filterspec,dialog) % prompt with filter and dialogue title
%
%   See >> help putfile  for more details about arguments for prompting
%
% If only one return argument, then throws error if not OK
%   >> file_full = putfilecheck (...)

if nargin==0 || (nargin==1 && isempty(varargin{1}))
    file_full=putfile;
    if ~isempty(file_full)
        ok=true; mess='';
    else
        ok=false; mess='No file given';
    end
else
    % If just one imput, try to intepret as a file first
    if nargin==1
        [file_full,ok,mess]=translate_write(varargin{1});
        if ok, return, end
    end
    % If one input that is not a file, or more than one input, assume want to prompt for file
    if isempty(varargin{1})
        varargin{1}='*.*';   % interpret empty filterspec as same as '*.*'
    end
    try
        file_full=putfile(varargin{:});
        if ~isempty(file_full)
            ok=true; mess='';
        else
            ok=false; mess='No file given';
        end
    catch
        file_full='';
        ok=false; mess='Check input argumenent(s)';
    end
end

% If not given ok as output argument, fail if ~ok
if nargout==1 && ~ok
    error(mess);
end
