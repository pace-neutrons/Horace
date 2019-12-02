function make_herbert_distribution_kit(varargin)
% function creates Herbert distribution kit packing all files necessary for
% Herbert to work into single zip file
%
%Usage:
%>>make_herbert_distribution_kit(['-full'])
% or
%>>make_herbert_distribution_kit([target_dir,'-run_by_horace',['-full']])
%
%where optional arguments are:
%'-full'      -- if present, request the demo and test files
%                to be included with the distribution
%
% the second form is used when script is run within
% make_horace_distribution_kit script
%
%
% To use Herbert  one has to unpack the resulting zip file and add the folder
% where the function herbert_init.m resides to the Matlab search path.
% alternatively, you can edit the file herbert_init.m.template, file and
% replace the variable $libisis_path$ and $Horathe_path$ by the actual
% folders  where the files herbert_init.m  and add to the search path the file
% herbert_on.m,
% after renaming the file herbert_on.m.template to file herbert_on.
%
% if called without parameters, this function p-codes Horace private
% folders, and removes C source code folders and if with parameter
% -- compress everything as it is which makes code suitable for further
% development.
%
% $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
%
%
options = {'-full','-run_by_horace'};
her_code_dir = fileparts(which('herbert_init')); % MUST have rootpath so that herbert_init, libisis_off included
her_root_dir = fileparts(her_code_dir );
if isempty(her_code_dir)
    error('MAKE_HERBERT_DISTRIBUTION_KIT:invalid_argument',' Herbert package have to be initiated to build herbert distribution kit');
end
[ok,err_mess,full_distribution,run_by_horace,argi] = parse_char_options(varargin,options);
if ~ok
    error('MAKE_HERBERT_DISTRIBUTION_KIT:invalid_argument',err_mess);
end
if run_by_horace
    horace_target_path = argi{1};
end

%
disp('!===================================================================!')
disp('!==> Preparing HERBERT distribution kit  ===========================!')
disp('!    Start collecting the Herbert program files ====================!')
%
current_dir  = pwd;
build_dir   =  current_dir;
if run_by_horace
    build_dir = horace_target_path;
end
[inside,common_root] = is_dir_inside(current_dir,build_dir);
% if inside Herbert package dir, go away from there:
if inside
    build_dir = fileparts(common_root);
end

if run_by_horace
    target_Dir = build_dir;
else
    target_Dir=fullfile(build_dir,'ISIS');
end
her_root_dir = fullfile(target_Dir,'Herbert');
her_dir =fullfile(her_root_dir ,'herbert_core');
copy_files_list(her_code_dir,her_dir);
% the file which should be modified to install Herbert
install_script=which('herbert_on.m.template');
mpi_worker    =which('worker_v2.m.template');
copyfile(mpi_worker,fullfile(target_Dir,'worker_v2.m.template'),'f');
if run_by_horace
    hor_install_script = fullfile(horace_target_path,'horace_on.m.template');
    merge_files(hor_install_script,install_script);
else
    copyfile(install_script,fullfile(target_Dir,'herbert_on.m.template'),'f');
end




% copy source code files from system directory
copy_files_list(fullfile(her_code_dir,'_LowLevelCode'),fullfile(her_dir,'_LowLevelCode'),'+_',...
    'h','cpp','c','f','f90','FOR','sln','vcproj','vfproj','txt','m');
%copy_files_list(fullfile(rootpath,'_notes'),fullfile(her_dir,'_notes'),'+_');

% copy unit tests and unit test suite if necessary
if ~no_tests
    copy_files_list(fullfile(her_code_dir,'_test'),fullfile(her_dir,'_test'),'+_');
end

%
disp('!    The HERBERT program files collected successfully ==============!')
%
if run_by_horace
else
    %
    disp('!    Start compressing all necessary files together ================!')
    %
    copyfile(install_script,fullfile(target_Dir,'herbert_on.m.template'),'f');
    
    her_file_name= 'herbert_distribution_kit.zip';
    if(exist(her_file_name,'file'))
        delete(her_file_name);
    end
    
    zip(her_file_name,target_Dir);
    if ~strcmp(pwd,current_dir)
        movefile(her_file_name,current_dir);
    end
    cd(current_dir);
    %
    disp('!    Files compressed. Deleting the auxiliary files and directories=!')
    
    if ~strncmp(target_Dir,her_code_dir,numel(her_code_dir))
        rmdir(target_Dir,'s');
    end
    disp('!    All done folks ================================================!')
    sound(-1:0.001:1);
    disp('!===================================================================!')
    
end
