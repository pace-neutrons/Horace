function update_svn_revision_info(pack_name)
% routine is used in git repository tree to update svn keys revision info
% (svn keys option) not supported by git
%
% Input:
% pack_name -- (horace or herbert) the name of the package to update
% revisioon info.
%
% Note: Currently supported keys are Revision and Date'
%
%

init_file_name = [lower(pack_name),'_init'];
pack_dir = fileparts(which(init_file_name));
skip_files = {'update_svn_revision_info','parse_rev_file',init_file_name};

if ~(exist(pack_dir,'dir')==7)
    error('UPDATE_SVN_REVISION_INFO:invalid_argument',...
        'Can not locate package init name %s',init_file_name);
end

persistent rev_str;
persistent rev_date;
persistent pack_name_stor;

if isempty(rev_str) || ~strcmpi(pack_name_stor,pack_name)
    pack_name_stor = pack_name;
    rev_file_name = [pack_name,'_version.m'];
    rev_file_name = fullfile(pack_dir,'admin',rev_file_name);
    if ~(exist(rev_file_name,'file') == 2)
        error('UPDATE_SVN_REVISION_INFO:invalid_argument',...
            'Can not locate revision file name: %s',rev_file_name);
    end
    [rev_str,rev_date]=parse_rev_file(rev_file_name);

end

parse_files_update_revision(pack_dir,rev_str,rev_date,skip_files);
up_root = fileparts(pack_dir);
code_dir = fullfile(up_root,'_LowLevelCode');
parse_files_update_revision(code_dir,rev_str,rev_date,{});
admin_dir = fullfile(up_root,'admin');
parse_files_update_revision(admin_dir,rev_str,rev_date,{});

function parse_files_update_revision(input_dir,rev_num,rev_date,skip_files)
% function lists all files and folders within the input directory,
% updates svn revision info of the files, found within the directory
% and runs recursively for all directories, found withinb the input
% directory.

files_list = dir(input_dir);
if isempty(files_list)
    return
end

use_extensions = {'.m','.h','.c','.cpp','.template'};

for i=1:numel(files_list)
    if files_list(i).name(1) == '.'
        continue;
    end
    if files_list(i).isdir
        sub_dir = fullfile(files_list(i).folder,files_list(i).name);
        parse_files_update_revision(sub_dir,rev_num,rev_date,skip_files)
    else
        [~,fn,fext] = fileparts(files_list(i).name);
        if ismember(fn,skip_files) || ~ismember(fext,use_extensions)
            continue;
        end
        file = fullfile(files_list(i).folder,files_list(i).name);
        if exist(file,'file')==2
            update_svn_revision(file,rev_num,rev_date);
        end
    end
end

function  update_svn_revision(file,rev_num,rev_date)
% update svn revision and date fields within the file, specified as input

fh = fopen(file,'rb+');
if fh<0
    error('UPDATE_SVN_REVISION_INFO:runtime_error',...
        ' Can not open file %s',file);
end
clob = onCleanup(@()fclose(fh));

cont = fread(fh,'*char');
try
    cont = regexprep(cont','(?<=\$Revisio).*?(?=\$\))',['n',rev_num,'($Date',rev_date]);
    fseek(fh,0,'bof');
    fwrite(fh,cont);    
catch
end

clear clob;


