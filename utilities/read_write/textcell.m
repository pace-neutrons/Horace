function [C,ok,mess] = textcell (file, max_size_MB)
% Reads lines of text from an ASCII file into a cell array of strings
%
%   >> C = textcell (file)                          % read from named file
%   >> [C,ok,mess] = textcell (file, max_size_MB)   % full format
%
% If only C is returned, then informational or error messages are printed to the screen.
%
% This is good for reading files up to, say 10-100MB, but should be used with caution above
% that size.

% Unix: <lf>; Windows: <cr><lf>; Mac (OSX and later): same as Unix

max_size_MB_default = 50;  % maximum file zise to be read
if nargin<2 || max_size_MB<=0
    max_size_MB=max_size_MB_default;
end
info=dir(file);
if ~isempty(info)
    if info.bytes>ceil(1048576*max_size_MB)
        C=cell(1,0); ok=false; mess=['File exceeds maximum size of ',num2str(max_size_MB),' MB'];
        if nargout<=1, error(mess), else return, end
    end
else
    C=cell(1,0); ok=false; mess=['File does not exist: ', file];
    if nargout<=1, error(mess), else return, end
end

% Read one long string from file
try
    str=fileread(file);
catch
    C=cell(1,0); ok=false; mess=['Error reading file: ', file];
    if nargout<=1, disp(mess), rethrow(lasterror), else return, end
end

% Return if empty
if isempty(str)
    C=cell(1,0); ok=true; mess=['Empty file: ', file];
    if nargout<=1, disp(mess), else return, end
end

% Determine if unix or Windows, and how last line is terminated
lf=find(double(str)==char(10));
cr=find(double(str)==char(13));
if numel(lf)==numel(cr) && all(lf-cr==1)    % Windows was used to create the text file
    nterm=2;
else
    nterm=1;
end
nlf=numel(lf);
if isempty(lf)||numel(str)~=lf(end)         % last line is not terminated with <lf>
    nline=nlf+1;
    lf_termination=false;
else
    nline=nlf;
    lf_termination=true;
end

% Read string into lines
C=cell(1,nline);
if nlf>0
    C{1}=str(1:lf(1)-nterm);
    for i=2:nlf
        C{i}=str(lf(i-1)+1:lf(i)-nterm);
    end
    if ~lf_termination
        C{end}=str(lf(end)+1:end);
    end
else
    C{1}=str;
end

% Message to screen
ok=true; mess=[num2str(nline) ' lines read from: ' file];
if nargout<=1, disp(mess), else return, end
    