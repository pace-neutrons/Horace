function report=count_lines(dirname)
% Count number of lines and characters in .m files in a give directory
%
%   >> report = count_lines             % current directory
%   >> report = count_lines(dirname)

% T.G.Perring   10 August 2007

if nargin==1
    files=dir(fullfile(dirname,'*.m'));
else
    files=dir('*.m');
end

report.nline=0;
report.nchar=0;
report.bytes=0;
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
    report.nline = report.nline + n;
    report.nchar = report.nchar + nc;
    report.bytes = report.bytes + files(ifile).bytes;
end
