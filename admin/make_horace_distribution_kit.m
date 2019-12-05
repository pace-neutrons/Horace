function make_horace_distribution_kit(varargin)
% function creates Horace distribution kit packing all files necessary for
% Horace to work into single zip file
%
%Usage:
%>>make_horace_distribution_kin(['-reveal_code','-compact'])
%
%where optional arguments are:
%'-reveal_code'  -- if present, do not request p-code Horace; default pCode
%                    the private Horace folders
%'-compact'         -- if present, request dropping the demo and test files
%                   with test folders, default -- compress demo and tests
%                   together with main code.
%'-noherbert'    -- do not pack Herbert together with Horace
%
% excludes (not copies to distribution) all files and subfolders of a folder where 
% _exclude_all.txt file is found
%
% excludes (not copies to distribution) all files of a folder where 
% _exclude_files.txt file is found but keeps subfolders of this folder and 
% processes the files of the subfolder.
%
% To use Horace  one has to unpack the resulting zip file and add the folder
% where the function Horace_init.m resides to the Matlab search path.
% alternatively, you can edit the file Horace_on.template, file and
% replace the variable $herbert_path$ and $Horathe_path$ by the actual
% folders  where the files Horace_init.m and libisis_init.m or herbert_init reside
% (Horace needs Libisis or Herbert to work)
% and add to the search path the file Horace_on.m,
% after renaming the file Horace_on.m.template to horace_on.m.
%
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)
%
%
% known keys
options = {'-reveal_code','-compact','-noherbert'};
[ok,err_mess,reveal_code,no_demo,no_herbert,argi] = parse_char_options(varargin,options);
if ~ok
    error('MAKE_HORACE_DISTRIBUTION_KIT:invalid_argument',err_mess);
end% default key values
%
common_files_to_distribute = {'license.txt','README.md','CMakeLists.txt'};


hor_root_dir = horace_git_root(); % MUST have rootpath so that horace_init, horace_off are included
%
disp('!===================================================================!')
disp('!==> Preparing HORACE distribution kit  ============================!')
disp('!    Start collecting the Horace program files =====================!')
%
%
current_dir  = pwd;
build_dir     = current_dir;
dir_to_return_to = build_dir;
% if inside Horace package dir, go away from there:
[inside,common_root] = is_dir_inside(build_dir,hor_root_dir);
% if inside Herbert package dir, go away from there:
while inside
    %current_dir = build_dir;
    build_dir = fileparts(common_root);
    [inside,common_root] = is_dir_inside(build_dir,hor_root_dir);
end

target_Dir=[build_dir,'/ISIS'];
horace_targ_dir = [target_Dir,'/Horace'];

% copy everything, which can be found core Horace folder
copy_files_list(fullfile(hor_root_dir,'horace_core'),fullfile(horace_targ_dir,'horace_core'));
% copy source code files from system directory
copy_files_list(fullfile(hor_root_dir,'_LowLevelCode'),fullfile(horace_targ_dir,'_LowLevelCode'),...
    '+_','h','cpp','c','sln','vcproj');
copy_files_list(fullfile(hor_root_dir,'admin'),fullfile(horace_targ_dir,'admin'));
copy_files_list(fullfile(hor_root_dir,'cmake'),fullfile(horace_targ_dir,'cmake'));
%
hor_on_template = fullfile(horace_targ_dir,'admin','horace_on.m.template');
copyfile(hor_on_template,fullfile(target_Dir,'horace_on.m.template'),'f');
delete(hor_on_template);
%
common_files_to_distribute = cellfun(@(x)(fullfile(hor_root_dir,x)),common_files_to_distribute,...
    'UniformOutput',false);
for i=1:numel(common_files_to_distribute)
    [ok,msg]=copyfile(common_files_to_distribute{i},horace_targ_dir,'f');
    if ~ok
        error('MAKE_HERBERT_DISTRIBUTION_KIT:runtime_error',...
            'Error copying file %s to destination %s, Message: %s',...
            common_files_to_distribute{i},horace_targ_dir,msg);
    end
end

%
% if necessary, copy demo and test folders
if ~no_demo
    % copy source code files from system directory
    copy_files_list(fullfile(hor_root_dir,'_test'),fullfile(horace_targ_dir,'_test'),'+_')
    copy_files_list(fullfile(hor_root_dir,'demo'),fullfile(horace_targ_dir,'demo'),'+_')    
end
%
disp('!    The HORACE program files collected successfully ==============!')
if(~reveal_code)
    disp('!    p-coding private Horace parts and deleting unnecessary folders=!')
    pCode_Horace_kit(fullfile(horace_targ_dir,'horace_core'));
    disp('!    Horace p-coding completed =====================================!')
end

% if Herbert used, add Herbert distribution kit to the distribution
if ~no_herbert
    argi{1}='-run_by_horace';
    if ~no_demo
        argi{2} = '-full';
    end
    make_herbert_distribution_kit(target_Dir,argi{:});
    pref='';
else
    pref='_only';
end
%
%
disp('!    Start compressing all necessary files together ================!')
%
if no_demo
    horace_file_name=['Horace',pref,'_nodemo.zip'];
else
    horace_file_name= ['horace',pref,'_distribution_kit.zip'];
end
horace_file_name=fullfile(current_dir,horace_file_name);
if(exist(horace_file_name,'file'))
    delete(horace_file_name);
end

cd(current_dir);
zip(horace_file_name,target_Dir);
cd(dir_to_return_to);

%[err,mess]=movefile(horace_file_name,current_dir);
%cd(current_dir);
%
disp('!    Files compressed. Deleting the auxiliary files and directories=!')
source_len = numel(hor_root_dir);
if ~strncmp(horace_targ_dir,hor_root_dir,source_len)
    rmdir(horace_targ_dir,'s');
end
if ~strcmpi(target_Dir,current_dir)
    rmdir(target_Dir,'s');
end

disp('!    All done folks ================================================!')
sound(-1:0.001:1);

disp('!===================================================================!')
