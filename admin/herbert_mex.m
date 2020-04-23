function herbert_mex(varargin)
% Create mex files for all the Herbert Fortran and C++ routines
%
%>> herbert_mex       -- this should automatically produce the mex files
%                        for Herbert
%>> herbert_mex options -- modify build options for Herbert (convenience)
%
% Available options:
% -prompt  --   ask to configure FORTRAN and C compiler, default not to ask
%               if provided, assume that compiler is configured and we are
%               building both Fortran and C parts of code
% -setmex    -- by default, successfully mexed  files are not set to be
%               used. when prompt is on, you are asked to set or not set
%               them up. use -setmex to use mex
%               files after successful compilation.
%
% -CPP_config  --configure C++ compiler to C++ -part of code, build C;
% -FOR_config -- configure Fortran compiler to build FORTRAN -part of code, build FORTRAN;
% -keep_lib  -- keep the intermediate Fortran library
% -use_lib   -- use the previously build library when building the mex-code (missing
%              library components will be added, will also invoke -keep_lib
% -missing   -- build only missing mex files, if not present, script
%               rebuilds all existing files
%
%   $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)
%
% root directory is assumed to be that in which mslice_init resides

% list of keys the script accepts
options={'-prompt','-setmex','-CPP','-keep_lib','-use_lib','-missing'};
%defaults:
[ok,mess,prompt4compiler,set_mex,configure_cpp,keep_lib,use_lib,use_missing] = parse_char_options(varargin,options);
if ~ok
    error(mess)
end
if use_missing
    missing = '-missing';
else
    missing ={};
end
if ~configure_cpp
    build_c = true;    
end

rootpath = herbert_root();
% Source code directories, and output directories:
%  - Herbert target directory:
herbert_mex_target_dir=fullfile(rootpath,'herbert_core','DLL',['_',computer],matlab_version_folder());
if ~exist(herbert_mex_target_dir,'dir')
    mkdir(herbert_mex_target_dir);
else
    ok = check_folder_permissions(herbert_mex_target_dir);
    if ~ok
        error('HERBERT_MEX:invalid_permissions','can not get write permissions to target folder %s',herbert_mex_target_dir)
    end
end
%  - mslice extras directory:
herbert_C_code_dir  =fullfile(rootpath,'_LowLevelCode','CPP');
% check folder permissions
ok = check_folder_permissions(lib_dir);
if ~ok
    error('HERBERT_MEX:invalid_permissions','can not get write permissions to auxiliary modules folder %s',lib_dir)
end


% -----------------------------------------------------
if prompt4compiler
    [build_c,build_fortran] = ask4Compiler(configure_cpp);
    if user_choice=='e'
        return;
    end
    set_mex = ask2SetMex();
end

try
    if build_c
        % build C++ files
        mex_single_c(fullfile(herbert_C_code_dir,'get_ascii_file'), herbert_mex_target_dir,...
            'get_ascii_file.cpp','IIget_ascii_file.cpp')
        
        try % failure in using this routine does not affect use_mex_C option as the routine is not checking it and
            % created for compartibility with older versions of matlab
            mex_single_c(fullfile(herbert_C_code_dir,'byte_stream'), herbert_mex_target_dir,...
                'byte_stream.cpp')
        catch
        end
        
        disp (' ')
        disp('!==================================================================!')
        disp('!  Succesfully created required C mex files   =====================!')
        if set_mex
            set(herbert_config,'use_mex_C',true);
            disp('!  Setting it to immediate use                     ================!')
        end
        disp('!==================================================================!')
        disp(' ')
        
    end
    
    
catch ex
    disp (' ')
    disp('!==================================================================!')
    disp('!  C mex-ing failed                                ================!')
    disp('!==================================================================!')
    disp(' ')
    set(herbert_config,'use_mex_C',false);
    rethrow(ex)
end

if ~keep_lib
    try
        rmdir(lib_dir,'s');
    catch
    end
end




%----------------------------------------------------------------
function mex_single_c(in_dir, out_dir, varargin)
% build a single mex routine from the list of files and objects
% provided in varargin
%
% with the input and output directories
% relative to the current directory
%
if nargin<3
    error('MEX_SINGLE:invalid_argument','needs at least three arguments, but got %d',nargin)
end

files = cell(nargin-2,1);
for i=1:nargin-2
    files{i} = make_filename(in_dir,varargin{i});
end
outdir = fullfile(out_dir,'');

[f_path,f_name]=fileparts(files{1});
targ_file=fullfile(outdir,[f_name,'.',mexext]);
if(exist(targ_file,'file'))
    try
        delete(targ_file)
    catch
        cd(old_path);
        error([' file: ',f_name,mexext,' locked. deleteon error: ',lasterr()]);
    end
end

fprintf('%s',['===>Mex file creation from: ',f_name,' ...'])
%mex('-v','-outdir',outdir,files{:});
mex('-outdir',outdir,files{:});
disp(' <=== completed');




function [build_c] = ask4Compiler(configure_cpp)
build_c = true;
build_fortran = true;
if ~(configure_cpp)
    disp('!==================================================================!')
    disp('! Would you like to select your compilers (win) or have configured !')
    disp('! your compiler yourself?:  y/n/e                                  !')
    disp('! y-select and configure;  n - already configured                  !')
    disp('! e (end)-- cancel script execution                                !')
    disp('!------------------------------------------------------------------!')
    disp('!------------------------------------------------------------------!')
    disp('! e -- cancel (end)                                                !')
    user_entry=input('! y/n/e :','s');
    user_entry=strtrim(lower(user_entry));
    user_choice = user_entry(1);
    disp(['!===> ' user_choice,' choosen                                                    !']);
    disp('!==================================================================!')
    if ~(user_choice=='y'||user_choice=='n')
        user_choice='e';
    end
    
end
if user_choice=='e'
    disp('!  canceled                                                        !')
    disp('!==================================================================!')
    build_c = false;
    build_fortran=false;
    return;
end

if configure_cpp
    disp('!==================================================================!')
    disp('! please, select your compilers    ================================!')
    mex -setup 
end


function set_mex = ask2SetMex()
disp('!==================================================================!')
disp('! Would you like to use mex files immidiately after successfull    !')
disp('! compilation?: y/n                                                !')
disp('! if no, you will be able to use them  by setting herbert          !')
disp('! configuration                                                    !')
disp('!>>set(herbert_config,''use_mex'',1,''use_mex_C'',1)                   !')
disp('! when compilation was successfull,                                !')
disp('! if yes, this script will do it for you                           !')
disp('!------------------------------------------------------------------!')
disp('!------------------------------------------------------------------!')
user_entry=input('! y/n :','s');
user_entry=strtrim(lower(user_entry));
user_choice = user_entry(1);
disp(['!===> ' user_choice,' choosen                                                    !']);
disp('!==================================================================!')

if strncmp(user_entry,'y',1)
    set_mex = true;
    return;
end
set_mex = false;
if ~strncmp(user_entry,'n',1)
    disp(['! unknown option ',user_entry,' selected, assuming it means no'])
end

function ok = check_folder_permissions(lib_dir)
folder_name = [lib_dir,'/tmp'];
ok =mkdir(folder_name );
if ok
    rmdir(folder_name,'s');
end