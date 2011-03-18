function report=count_lines_mfiles(dirname,report)
% Count number of lines and characters in .m files in a give directory
%
%   >> report = count_lines_mfiles                     % current directory
%   >> report = count_lines_mfiles(dirname)            % named directory
%   >> report = count_lines_mfiles(dirname, report)    % accumulate report from named directory

% T.G.Perring   10 August 2007

if nargin==1
    files=dir(fullfile(dirname,'*.m'));
else
    files=dir('*.m');
end

if nargin<2
    report.nfile=0;
    report.nline=0;
    report.nchar=0;
    report.bytes=0;
end

for ifile=1:length(files)
    i = 1;
    nc= 0;
    finish = 0;
    fid = fopen(files(ifile).name,'rt');
    while (~finish)
        tline = fgetl(fid);
        if (~isa(tline,'numeric'))
            i = i + 1;
            nc= nc + length(strtrim(tline));
        else
            n = i - 1;  % no. lines read from file
            finish = 1;
        end
    end
    fclose(fid);
    report.nfile = report.nfile + length(files);
    report.nline = report.nline + n;
    report.nchar = report.nchar + nc;
    report.bytes = report.bytes + files(ifile).bytes;
end
