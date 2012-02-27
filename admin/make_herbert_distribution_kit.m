function make_horace_distribution_kit(reveal_code)
% function creates Horace distribution kit packing all files necessary for
% Horace to work into single zip file
%
% To use Horace  one has to unpack the resulting zip file and add the folder
% where the function Horace_init.m resides to the matlab search path. 
% alternatively, you can edit the file Horace_on.mt, file and 
% replace the variable $libisis_path$ and $Horathe_path$ by the actual
% folders  where the files Horace_init.m and libisis_init.m reside (Horace
% needs Libisis to work) and add to the search path the file Horace_on.m, 
% after renaming the file Horace_on.mt.
% 
% if called withoug parameters, this function p-codes Horace private
% folders, and removes C source code folders and if with parameter 
% -- compress everything as it is which makes code suitable for further 
% development. 
%
% $Revision: 1851 $ ($Date: 2012-02-02 14:56:47 +0000 (Thu, 02 Feb 2012) $)
%
%
rootpath = fileparts(which('herbert_init')); % MUST have rootpath so that herbert_init, libisis_off included
%
disp('!===================================================================!')
disp('!==> Preparing HERBERT distributon kit  =============================!')
disp('!    Start collecting the Horace program files =====================!')
%
current_dir  = pwd;
build_dir   =current_dir; 
% if inside herbert package dir, go avay from there:
if strncmpi(build_dir,rootpath,numel(rootpath))
	cd(rootpath);
	cd('../');
    build_dir = pwd;
end

target_Dir=[build_dir,'/ISIS'];
her_dir = [target_Dir,'/Herbert'];
copy_files_list(rootpath,her_dir); 

% copy source code files from system directory
copy_files_list(fullfile(rootpath,'_LowLevelCode'),fullfile(her_dir,'_LowLevelCode'),'+_',...
                       'h','cpp','c','f','f90','for','sln','vcproj','vfproj','txt','m'); 
copy_files_list(fullfile(rootpath,'_notes'),fullfile(her_dir,'_notes'),'+_'); 
copy_files_list(fullfile(rootpath,'_test'),fullfile(her_dir,'_test'),'+_'); 

install_script=which('herbert_on.m.template');
copyfile(install_script,fullfile(target_Dir,'herbert_on.m.template'),'f');
%
disp('!    The HERBERT program files collected successfully ==============!')
%
%
disp('!    Start compressing all necessary files together ================!')
% 
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

if ~strncmp(target_Dir,rootpath,numel(rootpath))
    rmdir(target_Dir,'s');
end
disp('!    All done folks ================================================!')
sound(-1:0.001:1);
disp('!===================================================================!')
