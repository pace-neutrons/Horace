function file_out = getfile (filterspec,dialogtitle)
% Utility to get file name for input:  file_out = getfile (filterspec,dialogtitle)
%
% It is identical to the Matlab built-in function uigetfile, except that
%  - Returns filename including path; ='' if no file selected
%
%  - If a dialog box is opened, the default operation of uigetfile is altered:
%    (1) the default directory is that of the file most recently selected by getfile (if filespec is a simple string)
%    (2) the default extension is *.* rather than Matlab files
%    (3) it does not fail if dialogtitle is not a string
%
% Syntax:
%   >> filename = getfile (filterspec)
%   e.g.    >> file = getfile                          'Select File' box opened, default path is path
%                                                          of most recent file selected
%
%           >> file = getfile ('c:\temp')              'Select File' box opened, default path is c:\temp\
%
%           >> file = getfile ('*.spe')                 'Select File' box opened, default path is path
%                                                          of most recent file selected; default extension .spe
%
%           >> file = getfile ('d:\data\*.spe')         'Select File' box opened, default path is d:\data\
%                                                          and default extension is .spe
%
%           >> file = getfile ('c:\mprogs\add_spe.m')   Default file name
%
%   >> filename = getfile (filterspec, dialogtitle)     Title of 'Select File' box changed to dialogtitle
%
%
% See also putfile (essentially the same as uiputfile)

persistent path_save

% initialise the default path on first use
if (isempty(path_save))
    path_save ='';
end

% get file
if (nargin==0)
    [file,path] = uigetfile (fullfile(path_save,'*.*')); % default path is that when getfile last used (cf current directory)
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
                filterspec_in = fullfile(path_save,filterspec);  % no path at front, so use the default path
            else
                filterspec_in = filterspec;                      % otherwise use filterspec as is (i.e. ensure uigetfile acts as usual)
            end
        end
    elseif (iscellstr(filterspec) & (size(filterspec,2)==1|size(filterspec,2)==2))  % required cellstr format for uigetfile
        filterspec_in = filterspec;
    else
        error ('FILTERSPEC argument must be a string or an M by 1 or M by 2 cell array.')
    end
            
    if (nargin==1)
        [file,path] = uigetfile(filterspec_in);
    elseif (nargin==2)
        if (isa(dialogtitle,'char'))
            [file,path] = uigetfile(filterspec_in, dialogtitle);
        else
            [file,path] = uigetfile(filterspec_in);
        end
    end
end

% store path for future calls to getfile if user did not select cancel
if (isequal(file,0) | isequal(path,0))
    file_out = '';
else
    file_out = fullfile(path,file);
    path_save = path;
end