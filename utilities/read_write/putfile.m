function file_out = putfile (filterspec,dialogtitle)
% Utility to get file name for input:  file_out = putfile (filterspec,dialogtitle)
%
% It is identical to the Matlab built-in function uiputfile, except that
%  - Returns filename including path; ='' if no file selected
%
%  - If a dialog box is opened, the default operation of uiputfile is altered:
%    (1) the default directory is that of the file most recently selected by putfile (if filespec is a simple string)
%    (2) the default extension is *.* rather than Matlab files
%    (3) it does not fail if dialogtitle is not a string
%
% Syntax:
%   >> filename = putfile (filterspec)
%   e.g.    >> file = putfile                          'Select File' box opened, default path is path
%                                                          of most recent file selected
%
%           >> file = putfile ('c:\temp')              'Select File' box opened, default path is c:\temp\
%
%           >> file = putfile ('*.spe')                 'Select File' box opened, default path is path
%                                                          of most recent file selected; default extension .spe
%
%           >> file = putfile ('d:\data\*.spe')         'Select File' box opened, default path is d:\data\
%                                                          and default extension is .spe
%
%           >> file = putfile ('c:\mprogs\add_spe.m')   Default file name
%
%   >> filename = putfile (filterspec, dialogtitle)     Title of 'Select File' box changed to dialogtitle
%
%
% See also getfile (essentially the same as uigetfile)

% Code would be much neater if I knew how to pass an unknown length list of variables to a function

% Alternative I toyed with (code commented out below)
%  - It sensibly decide whether or not to open a dialog box: 
%       if just the name of a file that actually exists was passed (i.e. no dialog box argument), then file_out = filterspec,
%       and the routine is ignored. The routine can therefore be used in both interactive mode and script files.

persistent path_save

% initialise the default path on first use
if (isempty(path_save))
    path_save ='';
end

% get file
if (nargin==0)
    [file,path] = uiputfile (fullfile(path_save,'*.*')); % default path is that when putfile last used (cf current directory)
                                                         % no default extension (cf Matlab files)
elseif (nargin>0)
    if (isa(filterspec,'char') & size(filterspec,1)==1)  % filterspec is a one-dimensional string array
        if (exist(filterspec,'file')==7)                 % is a directory, ensure no default extension
            filterspec_in = fullfile(filterspec,'*.*');
        elseif (length(findstr('*.',filterspec))>=1 & min(findstr('*.',filterspec))) % filterspec begins '*.', so assume extensions list
            filterspec_in = fullfile(path_save,filterspec);
        else                                             
            [pathstr,name,ext] = fileparts(filterspec);
            if (isempty(pathstr))
                filterspec_in = fullfile(path_save,filterspec); % no path at front, so use the default path
            else
                filterspec_in = filterspec;                     % otherwise use filterspec as is (i.e. ensure uiputfile acts as usual)
            end
        end
    elseif (iscellstr(filterspec) & (size(filterspec,2)==1|size(filterspec,2)==2))
        filterspec_in = filterspec;
    else
        error ('FILTERSPEC argument must be a string or an M by 1 or M by 2 cell array.')
    end
            
    if (nargin==1)
        [file,path] = uiputfile(filterspec_in);
    elseif (nargin==2)
        if (isa(dialogtitle,'char'))
            [file,path] = uiputfile(filterspec_in, dialogtitle);
        else
            [file,path] = uiputfile(filterspec_in);
        end
    end
end

% store path for future calls to putfile if user did not select cancel
if (isequal(file,0) | isequal(path,0))
    file_out = '';
else
    file_out = fullfile(path,file);
    path_save = path;
end