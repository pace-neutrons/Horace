function wout = read_ascii (varargin)
% Read x,y or x,y,e column arrays into a IX_dataset_1d or array of IX_dataset_1d.
%   - Automatically detects if data is point or histogram data.
%   - Skips over non-numeric blocks of data
%   - Reads succesive block of numeric data, filling succesive datasets
%   - Columns can be separated by spaces, commas or tabs. Commas and tabs
%    can be used to indicate columns to skip e.g. the line
%                   13.2, ,15.8
%    puts 13.2 in column 1 and 15.8 in column 3.
%
%
% Auto-detect a single dataset:
% -----------------------------
%   >> w = read_ascii           % prompts for file
%   >> w = read_ascii (file)    % read from named file
%
% If just two columns of numeric data are found, then these are used as the x and y values; if
% three or more columns are found then the first three columns are used as the x,y,e values:
%
%
% Give columns to read into one or more workspaces:
% -------------------------------------------------
% (Note that if the file is not given, then prompts for the file)
%   >> w = read_ascii (..., 4,6)       % columns 4,6 are x,y; no error bars
%   >> w = read_ascii (..., 3,5,2)     % columns 3,5, and 2 are x,y,e respectively
%   >> w = read_ascii (..., 4, [6,8,10], [7,9,11])
%        % three spectra, x data is col 4, then y-e are cols 6,7, cols 8,9, cols 10,11 respectively
%   >> w = read_ascii (..., [4,7,10], [5,8,11], [6,9,12])
%        % three spectra, x-y-e are cols 4,5,6, cols 7,8,9, cols 10,11,12 respectively
%
%
%
% To return the data as an array:
%
%   >> arr = read_ascii (file,0)  % read from named file
%   >> arr = read_ascii (0)       % prompts for file

wout=read_ascii(IX_dataset_1d,varargin{:});
