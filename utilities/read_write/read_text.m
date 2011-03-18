function tline = read_text (file)
% Reads lines of text from an ASCII file into a cell array.
%
% Syntax:
%   >> w = read_text (file)    % read from named file
%   >> w = read_text           % prompts for file
%

nlines = 10000;  % max. number of lines that can be read from file

% Get file name - prompt if file does not exist (using file to set default seach location and extension)
% ------------------------------------------------------------------------------------------------------
% Get file name - prompt if file does not exist 
if ~exist('file','var')
    file_internal=getfile;
    if isempty(file_internal), error('No file given'), end
else
    [file_internal,ok,mess]=translate_read(file);   % try to intepret as a file
    if ~ok
        file_internal=getfile(file);
        if isempty(file_internal), error('No file given'), end
    end
end


% Read data
% -----------
fid = fopen(file_internal);
i = 1;
finish = 0;
while (~finish)
    tline{i} = fgetl(fid);
    if (~isa(tline{i},'numeric'))
        i = i + 1;
        if (i>nlines)
            disp('Maximum number of lines read from file')
            n = nlines;
            finish = 1;
        end
    else
        n = i - 1;  % no. lines read from file
        finish = 1;
    end
end
fclose(fid);

disp ([num2str(n) ' lines read from ' file_internal])
