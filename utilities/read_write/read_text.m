function tline = read_text (file, max_size_MB)
% Reads lines of text from an ASCII file into a cell array of strings
%
% Syntax:
%   >> w = read_text (file)    % read from named file
%   >> w = read_text           % prompts for file
%

if ~exist('max_size_MB','var')
    max_size_MB=50;  % max. number of lines that can be read from file
elseif max_size_MB<=0
    error('Maximum file size must be greater than zero')
end

% Get file name - prompt if file does not exist (using file to set default seach location and extension)
% ------------------------------------------------------------------------------------------------------
if ~exist('file','var'), file=''; end
[file_full,ok,mess]=getfilecheck(file);
if ~ok, error(mess), end

% Read data
% -----------
tline = textcell (file,max_size_MB);


% Earlier version (prior to 4 Dec 2012) - retain for time being as reading ASCII files on different architectures can be tricky
% ---------------
%
% nlines = 1000000;  % max. number of lines that can be read from file
% 
% % Get file name - prompt if file does not exist (using file to set default seach location and extension)
% % ------------------------------------------------------------------------------------------------------
% if ~exist('file','var'), file=''; end
% [file_full,ok,mess]=getfilecheck(file);
% if ~ok, error(mess), end
% 
% % Read data
% -----------
% fid = fopen(file_full);
% i = 1;
% finish = 0;
% while (~finish)
%     tline{i} = fgetl(fid);
%     if (~isa(tline{i},'numeric'))
%         i = i + 1;
%         if (i>nlines)
%             disp('Maximum number of lines read from file')
%             n = nlines;
%             finish = 1;
%         end
%     else
%         n = i - 1;  % no. lines read from file
%         tline=tline(1:end-1);
%         finish = 1;
%     end
% end
% fclose(fid);
% 
% disp ([num2str(n) ' lines read from ' file_full])
