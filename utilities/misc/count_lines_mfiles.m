function report=count_lines_mfiles(varargin)
% Count number of lines and characters in .m files in a give directory
%
%   >> report = count_lines_mfiles              % current directory
%   >> report = count_lines_mfiles(directory)   % named directory
%   >> report = count_lines_mfiles(...,'-all')  % recursively through sub-directories too
%
% Skips folders with name '.svn'

% T.G.Perring   10 August 2007  Original
%               20 August 2011  Modified

% Parse input
% ------------
if ~isempty(varargin) && ischar(varargin{end}) && ~isempty(varargin{end}) && strncmpi(lower(varargin{end}),'-all',min(numel(varargin{end}),4))
    recurse=true;
    narg=nargin-1;
else
    recurse=false;
    narg=nargin;
end
if narg>=1
    directory=varargin{1};
    if ~exist(directory,'dir')
        error(['Directory ',directory,' does not exist.'])
    end
else
    directory=pwd;
end
if narg>=2
    report=varargin{2};
else
    report.nfile=0;
    report.nline=0;
    report.ncodeline=0;
    report.ncommline=0;
    report.nblankline=0;
    report.nchar=0;
    report.bytes=0;
end
if narg>=3
    error('Check input arguments')
end

% Loop over all directories
% --------------------------
if recurse
    directories=dir_name_list(directory,'','.svn');    % skip svn work folders
    for i=1:numel(directories)
        sub_directory=directories{i};
        % ignore '.' and '..'
        if (strcmp(sub_directory,'.') || strcmp(sub_directory,'..'))
            continue;
        end
        % Recurse down
        full_directory=fullfile(directory,sub_directory);
        report=count_lines_mfiles(full_directory,report,'-all');
    end
end

% Run function (recursion operates from the bottom of each branch)
% -----------------------------------------------------------------
files=dir(fullfile(directory,'*.m'));
disp(directory)
for ifile=1:length(files)
    nline = 0;
    ncodeline = 0;
    ncommline = 0;
    nblankline = 0;
    nchar= 0;
    finish = 0;
    fname=fullfile(directory,files(ifile).name);
    fid = fopen(fname,'rt');
    if fid<0
        disp(['Cannot open: ',fname])
    else
        while (~finish)
            tline = fgetl(fid);
            if (~isa(tline,'numeric'))
                nline = nline + 1;
                strline = strtrim(tline);
                if ~isempty(strline)
                    if strline(1:1)~='%'
                        ncodeline = ncodeline + 1;
                    else
                        ncommline = ncommline + 1;
                    end
                else
                    nblankline = nblankline + 1;
                end
                nchar = nchar + numel(strline);
            else
                finish = 1;
            end
        end
        fclose(fid);
        report.nfile = report.nfile + 1;
        report.nline = report.nline + nline;
        report.ncodeline = report.ncodeline + ncodeline;
        report.ncommline = report.ncommline + ncommline;
        report.nblankline = report.nblankline + nblankline;
        report.nchar = report.nchar + nchar;
        report.bytes = report.bytes + files(ifile).bytes;
    end
end
