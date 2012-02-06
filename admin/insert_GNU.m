function insert_GNU
%
% Function to insert the GPL text into the help m-file associated with
% every p-file in Horace.
%
% This function is used AFTER the p-code has been generated, since by doing
% this we can write the relevant text at the end of each m-file.
%
% Ideally, for files that have not been p-coded, we want the GPL license to
% appear after the help section at the head of the code.
%
% R.A. Ewings 7/7/09
%


%First we deal with folders in which the m-files are stubs containing just
%the help info:

fileroot=pwd;

filepath{1}='@d0d\private';
filepath{2}='@d1d\private';
filepath{3}='@d2d\private';
filepath{4}='@d3d\private';
filepath{5}='@d4d\private';
filepath{6}='@sqw';
filepath{7}='@sqw\private';
filepath{8}='@sigvar';
filepath{9}='@sigvar\private';

filepath{10}='libisis\@d1d';
filepath{11}='libisis\@d2d';
filepath{12}='libisis\@d3d';
filepath{13}='libisis\@sqw';
filepath{14}='private';

% for i=1:numel(filepath)
%     generate_license_append(fullfile(fileroot,filepath{i}));%deals with simple case
%     %where we append the license to the end of the file.
% end

%============

%We now need to work out how to add the license text at the end of regular
%comments in m-files which are not stubs.

mfilepath{1}='@d0d';
mfilepath{2}='@d1d';
mfilepath{3}='@d2d';
mfilepath{4}='@d3d';
mfilepath{5}='@d4d';

% for i=1:numel(mfilepath)
%     generate_license_insert(fullfile(fileroot,mfilepath{i}))
%     %deals with more complex case when we wish to put copyright etc
%     %between the help code and the real code.
% end

%===========

%Finally insert license text into file in the root directory.

generate_license_insert(fileroot);


%==========================================================================

function generate_license_append(directory)

curr_dir = pwd;
fprintf('Adding license text in %s:\n',pwd);

% Work to be done only if there is an m-file other than contents.m
mfiles=dir(fullfile(directory,'*.m'));
if isempty(mfiles) || (numel(mfiles)==1 && strcmpi(mfiles(1).name,'contents.m'))
    fprintf('No m-files to which license needs to be added \n')
    return
end

%This is the GPL text:

license_text0='% Copyright 2007, 2008, 2009 Toby Perring, Russell Ewings, Alex Buts, Joost van Duijn, Ibon Bustinduy, Dean Whittaker';
license_text1='% This file is part of Horace';
license_text2='% Horace is free software: you can redistribute it and/or modify';
license_text3='% it under the terms of the GNU General Public License as published by';
license_text4='% the Free Software Foundation, either version 3 of the License, or';
license_text5='% (at your option) any later version.';
license_text6='% Horace is distributed in the hope that it will be useful,';
license_text7='% but WITHOUT ANY WARRANTY; without even the implied warranty of';
license_text8='% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the';
license_text9='% GNU General Public License for more details. ';
license_text10='% You should have received a copy of the GNU General Public License';
license_text11='% along with Horace.  If not, see <http://www.gnu.org/licenses/>. ';

% Move to directory
cd(directory);

%Add license text
for i=1:numel(mfiles)
    current_mfile = mfiles(i).name;
    if(~strcmpi(current_mfile,'contents.m'))
        fprintf('    %s\n',current_mfile);
        fid = fopen(current_mfile,'a+');
        fprintf(fid,'%s\n','');%blank line first
        fprintf(fid,'%s\n',license_text0);
        fprintf(fid,'%s\n',license_text1);
        fprintf(fid,'%s\n',license_text2);
        fprintf(fid,'%s\n',license_text3);
        fprintf(fid,'%s\n',license_text4);
        fprintf(fid,'%s\n',license_text5);
        fprintf(fid,'%s\n',license_text6);
        fprintf(fid,'%s\n',license_text7);
        fprintf(fid,'%s\n',license_text8);
        fprintf(fid,'%s\n',license_text9);
        fprintf(fid,'%s\n',license_text10);
        fprintf(fid,'%s\n',license_text11);
        fclose(fid);
    end
end

%==========================================================================

function generate_license_insert(directory)

curr_dir = pwd;
fprintf('Adding license text in %s:\n',pwd);

% Work to be done only if there is an m-file other than contents.m
mfiles=dir(fullfile(directory,'*.m'));
if isempty(mfiles) || (numel(mfiles)==1 && strcmpi(mfiles(1).name,'contents.m'))
    fprintf('No m-files to which license needs to be added \n')
    return
end

%This is the GPL text:

license_text0='% Copyright 2007, 2008, 2009 Toby Perring, Russell Ewings, Alex Buts, Joost van Duijn, Ibon Bustinduy, Dean Whittaker';
license_text1='% This file is part of Horace';
license_text2='% Horace is free software: you can redistribute it and/or modify';
license_text3='% it under the terms of the GNU General Public License as published by';
license_text4='% the Free Software Foundation, either version 3 of the License, or';
license_text5='% (at your option) any later version.';
license_text6='% Horace is distributed in the hope that it will be useful,';
license_text7='% but WITHOUT ANY WARRANTY; without even the implied warranty of';
license_text8='% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the';
license_text9='% GNU General Public License for more details. ';
license_text10='% You should have received a copy of the GNU General Public License';
license_text11='% along with Horace.  If not, see <http://www.gnu.org/licenses/>. ';

% Move to directory
cd(directory);

%Add license text
for i=1:numel(mfiles)
    current_mfile = mfiles(i).name;
    if(~strcmpi(current_mfile,'contents.m'))
        %
        % First check that the function is not one with no input arguments:
        %
        inargs=check_input_args(current_mfile);
        %
        if inargs
            %=
            endfunc=ffind_horace(current_mfile,')');
            fid=fopen(current_mfile,'r');
            status=fseek(fid,endfunc,'bof');
            funcline=fgets(fid);
            %
            helptext=true;
            numchars=0;
            while helptext
                nextline=fgets(fid);
                if ~isempty(nextline)
                    if strcmp(nextline(1),'%')
                        helptext=true;
                        numchars=numchars+numel(nextline);
                    else
                        helptext=false;
                    end
                else
                    helptext=false;
                end
            end
            fclose(fid);
            %
            fid=fopen(current_mfile,'r');
            fulltext=fscanf(fid,'%c',inf);%reads all text in file
            firstbit=fulltext(1:(numchars+endfunc));
            lastbit=fulltext((numchars+endfunc+1):end);
            fclose(fid);
            %
            fid=fopen(current_mfile,'w');%overwrite with new text below:
            fprintf(fid,'%s\n',firstbit);
            fprintf(fid,'%s\n','');%blank line
            fprintf(fid,'%s\n',license_text0);
            fprintf(fid,'%s\n',license_text1);
            fprintf(fid,'%s\n',license_text2);
            fprintf(fid,'%s\n',license_text3);
            fprintf(fid,'%s\n',license_text4);
            fprintf(fid,'%s\n',license_text5);
            fprintf(fid,'%s\n',license_text6);
            fprintf(fid,'%s\n',license_text7);
            fprintf(fid,'%s\n',license_text8);
            fprintf(fid,'%s\n',license_text9);
            fprintf(fid,'%s\n',license_text10);
            fprintf(fid,'%s\n',license_text11);
            fprintf(fid,'%s\n','');%another blank line
            fprintf(fid,'%s\n',lastbit);%the remainder of the function's text
            fclose(fid);
        else
            add_license_noargin(current_mfile);
        end
    end
end

%==========================================================================
function out=check_input_args(mfile)
%
% check if function has input arguments. If none then we need to add
% license in a special way.
%

fid=fopen(mfile);
firstline=fgetl(fid);
firstline=strtrim(firstline);%get rid of white space
if strcmp(firstline(end),')')
    out=true;
elseif strcmp(firstline(end-2:end),'...')
    nextline=fgetl(fid);%case where input is over more than 1 line
    nextline=strtrim(nextline);
    if strcmp(nextline(end),')')
        out=true;
    elseif strcmp(nextline(end-2:end),'...')
        nextline=fgetl(fid);%case where input is over more than 2 lines
        nextline=strtrim(nextline);
        if strcmp(nextline(end),')')
            out=true;
        else
            out=false;%no 3 line function declarations
        end
    else
        out=false;
    end
else
    out=false;
end
fclose(fid);

%===================


function add_license_noargin(mfile)
%
%function to append the license info to m-code where nargin=0 (e.g.
%horace_init).
%

%Simplest thing to do in this case is simply to add the licesnse text at
%the end of the file.

license_text0='% Copyright 2007, 2008, 2009 Toby Perring, Russell Ewings, Alex Buts, Joost van Duijn, Ibon Bustinduy, Dean Whittaker';
license_text1='% This file is part of Horace';
license_text2='% Horace is free software: you can redistribute it and/or modify';
license_text3='% it under the terms of the GNU General Public License as published by';
license_text4='% the Free Software Foundation, either version 3 of the License, or';
license_text5='% (at your option) any later version.';
license_text6='% Horace is distributed in the hope that it will be useful,';
license_text7='% but WITHOUT ANY WARRANTY; without even the implied warranty of';
license_text8='% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the';
license_text9='% GNU General Public License for more details. ';
license_text10='% You should have received a copy of the GNU General Public License';
license_text11='% along with Horace.  If not, see <http://www.gnu.org/licenses/>. ';

fid=fopen(mfile,'a+');
fprintf(fid,'%s\n','');%blank line
fprintf(fid,'%s\n',license_text0);
fprintf(fid,'%s\n',license_text1);
fprintf(fid,'%s\n',license_text2);
fprintf(fid,'%s\n',license_text3);
fprintf(fid,'%s\n',license_text4);
fprintf(fid,'%s\n',license_text5);
fprintf(fid,'%s\n',license_text6);
fprintf(fid,'%s\n',license_text7);
fprintf(fid,'%s\n',license_text8);
fprintf(fid,'%s\n',license_text9);
fprintf(fid,'%s\n',license_text10);
fprintf(fid,'%s\n',license_text11);
fprintf(fid,'%s\n','');%another blank line
fclose(fid);

