function banner_to_screen(varargin)
% Write a banner to the screen containing the provided text
%
%   >> banner_to_screen(str)
%   >> banner_to_screen(str,'top')      % Top banner format (default)
%   >> banner_to_screen(str'bottom')    % Bottom banner format
%   >> banner_to_screen(str,nlines)     % Custom format
%
% Input:
% ------
%   str     String to be printed to screen, or cell array of strings
%
% Options:
%  'top'    Top banner format (default)
%  'bottom' Bottom banner format
%   nlines  Array length two containing [nbanner,nblank], where:
%               nbasnner  Number of banner lines to be printed (default 2)
%               nblank    Number of spacer lines above and below the text
%                        that separate from the surrounding banner lines (default 1)
%
% Examples:
%   >> 


% Parse input
% -----------
if get(herbert_config,'log_level')<0
    return;
end
str=varargin{1};

if nargin==2
    if ischar(varargin{2}) && ~isempty(varargin{2})
        if strncmpi(varargin{2},'top',numel(varargin{2}))
            nlines=[2,1];   % default top banner format
        elseif strncmpi(varargin{2},'bottom',numel(varargin{2}))
            nlines=[1,0];   % default bottom banner format
        else
            error('Unrecognised option')
        end
    elseif isnumeric(varargin{2})&& numel(varargin{2})==2
        nlines=varargin{2};
    else
        error('Unrecognised option')
    end
else
    nlines=[2,1];   % default top banner format
end


% Print to screen
%----------------
banner_line='================================================================================';
spacer_line='===                                                                          ===';

% Print new line
fprintf(1,'\n') ;

% Top of banner
for i=1:nlines(1);
    disp(banner_line)
end
for i=1:nlines(2)
    disp(spacer_line)
end

% Text
if ~iscellstr(str), str={str}; end
for i=1:numel(str)
    str_tmp=deblank(str{i});
    nchar=numel(str_tmp);
    str_out=spacer_line;
    if nchar<=69
        str_out(8:7+nchar)=str_tmp;
    else
        str_out(8:76)=str_tmp(1:69);
    end
    disp(str_out)
end

% Bottom of banner
for i=1:nlines(2)
    disp(spacer_line)
end
for i=1:nlines(1);
    disp(banner_line)
end
