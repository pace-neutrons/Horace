function herbert_mex(varargin)
% Create mex files for all the Herbert C++ routines
%
%>> herbert_mex       -- this should automatically produce the mex files
%                        for Herbert
%>> herbert_mex options -- modify build options for Herbert (convenience)
%
% Available options:
% -prompt  --   ask to configure C compiler, default not to ask
%               if provided, assume that compiler is configured
% -setmex    -- by default, successfully mexed  files are not set to be
%               used. when prompt is on, you are asked to set or not set
%               them up. use -setmex to use mex files after successful
%               compilation.
% -CPP_config  --configure C++ compiler to C++ -part of code, build C;
% -missing   -- build only missing mex files, if not present, script
%               rebuilds all existing files
%
% root directory is assumed to be that in which mslice_init resides

% list of keys the script accepts
options={'-prompt','-setmex','-CPP','-missing'};
%defaults:
[ok,mess,prompt4compiler,set_mex,configure_cpp,use_missing] = parse_char_options(varargin,options);
if ~ok
    error(mess)
end
if use_missing
%     missing = '-missing';
% else
%     missing ={};
end
if ~configure_cpp
    build_c = true;
end

rootpath = herbert_root();
% Source code directories, and output directories:
%  - Herbert target directory:
herbert_mex_target_dir=fullfile(rootpath,'herbert_core','DLL',['_',computer],matlab_version_folder());
if ~is_folder(herbert_mex_target_dir)
    mkdir(herbert_mex_target_dir);
else
    ok = check_folder_permissions(herbert_mex_target_dir);
    if ~ok
        error('HERBERT_MEX:invalid_permissions','can not get write permissions to target folder %s',herbert_mex_target_dir)
    end
end
%  - mslice extras directory:
herbert_C_code_dir  =fullfile(rootpath,'_LowLevelCode','cpp');
% check folder permissions


% -----------------------------------------------------
if prompt4compiler
    build_c = ask4Compiler(configure_cpp);
    if user_choice=='e'
        return;
    end
    set_mex = ask2SetMex();
end
% build package version
build_version_h(rootpath)
try
    if build_c
        % build C++ files
        mex_single_c(fullfile(herbert_C_code_dir,'get_ascii_file'), herbert_mex_target_dir,...
            'get_ascii_file.cpp','IIget_ascii_file.cpp')
        mex_single_c(fullfile(herbert_C_code_dir,'serialiser'), herbert_mex_target_dir,...
            'c_serialise.cpp')
        mex_single_c(fullfile(herbert_C_code_dir,'serialiser'), herbert_mex_target_dir,...
            'c_deserialise.cpp')
        mex_single_c(fullfile(herbert_C_code_dir,'serialiser'), herbert_mex_target_dir,...
            'c_serial_size.cpp')
        

        try % failure in using this routine does not affect use_mex option as the routine is not checking it and
            % created for compatibility with older versions of Matlab
            mex_single_c(fullfile(herbert_C_code_dir,'byte_stream'), herbert_mex_target_dir,...
                'byte_stream.cpp')
        catch
        end

        disp (' ')
        disp('!==================================================================!')
        disp('!  Successfully created required C mex files   =====================!')
        if set_mex
            set(herbert_config,'use_mex',true);
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
    set(herbert_config,'use_mex',false);
    rethrow(ex)
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

[~,f_name]=fileparts(files{1});
targ_file=fullfile(outdir,[f_name,'.',mexext]);
if(is_file(targ_file))
    try
        delete(targ_file)
    catch ME
        cd(old_path);
        error([' file: ',f_name,mexext,' locked. deletion error: ', ME]);
    end
end

fprintf('%s',['===>Mex file creation from: ',f_name,' ...'])
%mex('-v','-outdir',outdir,files{:});
mex('-outdir',outdir,files{:});
disp(' <=== completed');




function build_c = ask4Compiler(configure_cpp)
build_c = true;
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
    disp(['!===> ' user_choice,' chosen                                                     !']);
    disp('!==================================================================!')
    if ~(user_choice=='y'||user_choice=='n')
        user_choice='e';
    end

end
if user_choice=='e'
    disp('!  cancelled                                                       !')
    disp('!==================================================================!')
    build_c = false;
    return;
end

if configure_cpp
    disp('!==================================================================!')
    disp('! please, select your compilers    ================================!')
    mex -setup
end


function set_mex = ask2SetMex()
disp('!==================================================================!')
disp('! Would you like to use mex files immediately after successful    !')
disp('! compilation?: y/n                                                !')
disp('! if no, you will be able to use them  by setting herbert          !')
disp('! configuration                                                    !')
disp('!>>set(herbert_config,''use_mex'',1,)                              !')
disp('! when compilation was successful,                                 !')
disp('! if yes, this script will do it for you                           !')
disp('!------------------------------------------------------------------!')
disp('!------------------------------------------------------------------!')
user_entry=input('! y/n :','s');
user_entry=strtrim(lower(user_entry));
user_choice = user_entry(1);
disp(['!===> ' user_choice,' chosen                                                    !']);
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