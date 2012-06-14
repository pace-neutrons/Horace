function obj_name=build_fortran_module(source_dir,target_dir,file_name,include_dir,use_lib)
% function compiles single fortran module to use it as part of system
% independent library accessible from Matlab.
% 
%Input:
%source_dir  -- the folder with source fortran file
%targer_dir  -- folder to place resulting obj file
%file_name   -- the name of the file to compile
%include_dir -- the name of the folder with include files or *.mod files.
%               Usually should coinside with target_dir for simple and
%               normal compilations
%use_lib     -- the switch, which informs what to do with existing target
%               file. If use_lib is false, existing target file will be
%               removed, and if true -- retained. Then compilation will mot
%               proceed assuming that it has already been performed.
%
%   $Rev$ ($Date$)
%
%
[ps,base_name]=fileparts(file_name);
% identify platform specific file extension
obj_ext = '.o';
if ispc
    obj_ext ='.obj';
end

obj_name=fullfile(target_dir,[base_name,obj_ext]);
if use_lib
    if exist(obj_name,'file')
        return;
    end
end

fprintf('%s',['---> compiling module: ',base_name, '  ...']);
file_name = make_filename(source_dir,file_name);
mex('-c',['-I',include_dir],'-outdir',target_dir,file_name);
wkdir = pwd;
mod_name =[base_name,'.mod'];
if exist(mod_name,'file')
    movefile(fullfile(wkdir,mod_name),fullfile(target_dir,mod_name),'f');
end
disp('---< completed');
