function herbert_mex()
% Create mex files for all the herbert fortran and C++ routines
%
%   >> herbert_mex       -- this should automatically produce the mex 
%
%
%
%   $Rev: 200 $ ($Date: 2011-11-24 14:05:19 +0000 (Thu, 24 Nov 2011) $)
%
start_dir=pwd;
% root directory is assumed to be that in which mslice_init resides
rootpath = fileparts(which('herbert_init'));
cd(rootpath)


% -----------------------------------------------------
disp('!==================================================================!')
disp('! Would you like to select your compilers (win) or have configured !')
disp('! your compiler yourself?:  y/n/c/f/e                              !')
disp('! y-select and configure;  n - already configured                  !')
disp('! c or f allow you to build C or FORTRAN part of the program       !')
disp('!        having configured proper compiler yourself                !')
disp('!------------------------------------------------------------------!')
disp('! If you are going to build standalone version, the compiler has to!')
disp('! be configured for static linkage (e.g. /MT for VS C compiler or  !')
disp('! /libs:static for ifort compiler)                                 !')
disp('!------------------------------------------------------------------!')
disp('! e -- cancel (end)                                                !')
user_entry=input('! y/n/c/f/e :','s');
user_entry=strtrim(lower(user_entry));
user_choise = user_entry(1);
disp(['!===> ' user_choise,' choosen                                                    !']);
disp('!==================================================================!')
if ~(user_choise=='y'||user_choise=='n'||user_choise=='c'||user_choise=='f')
    user_choise='e';
end
if user_choise=='e'
    disp('!  canceled                                                        !')        
    disp('!==================================================================!')    
    return;
end

if user_choise=='y'
    % Prompt for fortran compiler
    disp('!==================================================================!')
    disp('! please, select your FORTRAN compiler  ===========================!')
    mex -setup
end
% Source code directories, and output directories:
%  - herbert target directrory:
herbert_mex_target_dir=fullfile(rootpath,'DLL');
%  - mslice extras directory:
mslice_extras_code_dir =fullfile(rootpath,'mslice_extras','_fortran');
mslice_Ccode_dir_base  =fullfile(rootpath,'mslice','_LowLevelCode');

% choose the code version
if ~exist('option','var')
    code_kind = '32and64after7.4';
    mslice_fortcode_rel_dir=fullfile('mslice','_LowLevelCode',code_kind);
else
    if ~(strncmpi(option,'32',2)||strncmpi(option,'64',2)||strncmpi(option,'mac_32',3)||strncmpi(option,'original_32',3))
        error('The given installation option have to be one of: (''32'',''mac_32'',''64'',''original_32'')')    
    else
        warning('MSLICE_MEX:Old_Code','You are trying to compile the old version of the code, which is not supported by recent Matalb versions');
    end
    mslice_fortcode_rel_dir=fullfile('mslice','_LowLevelCode',[option,'bit']);    
    code_kind = option;

end

mslice_Ccode_dir       = fullfile(mslice_Ccode_dir_base ,code_kind);

try   
    switch code_kind
        case 'original_32'
            mex_single (mslice_fortcode_rel_dir, mslice_mex_target_dir, 'avpix_df.F')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_target_dir, 'cut2d_df.F')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_target_dir, 'cut3d_df.F')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_target_dir, 'cut3dxye_df.F')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_target_dir, 'load_spe_df.F')
            % mex_single (mslice_fortcode_rel_dir, mslice_mex_target_dir, 'ms_iris.F')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_target_dir, 'put_spe_fortran.F')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_target_dir, 'slice_df.F')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_target_dir, 'spe2proj_df.F')
            
            mex_single (mslice_extras_code_dir, mslice_mex_target_dir, 'slice_df_full.F')

        case 'mac_32'
            mex_single (mslice_fortcode_rel_dir, mslice_mex_target_dir, 'avpix_df.F')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_target_dir, 'cut2d_df.F')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_target_dir, 'cut3d_df.F')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_target_dir, 'cut3dxye_df.F')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_target_dir, 'load_spe_df.F')
            % mex_single (mslice_fortcode_rel_dir, mslice_mex_target_dir, 'ms_iris.F')
            % mex_single (mslice_fortcode_rel_dir, mslice_mex_target_dir, 'put_spe_fortran.F')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_target_dir, 'slice_df.F')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_target_dir, 'spe2proj_df.F')
        
            % mex_single (mslice_extras_code_dir, mslice_extras_mex_rel_dir, 'slice_df_full.F')
        case {'32bit','64bit'}
            mex_single (mslice_fortcode_rel_dir, mslice_mex_target_dir, 'avpix_df.f90')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_target_dir, 'cut2d_df.f90')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_target_dir, 'cut3d_df.f90')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_target_dir, 'cut3dxye_df.f90')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_target_dir, 'load_spe_df.f90')
            % mex_single (mslice_fortcode_rel_dir, mslice_mex_target_dir, 'ms_iris.f90')
            % mex_single (mslice_fortcode_rel_dir, mslice_mex_target_dir, 'put_spe_fortran.f90')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_target_dir, 'slice_df.f90')
            mex_single (mslice_fortcode_rel_dir, mslice_mex_target_dir, 'spe2proj_df.f90')
    
            % mex_single (mslice_extras_code_dir, mslice_mex_target_dir, 'slice_df_full.f90')          

        otherwise		
         if user_choise ~= 'c'
			cd(mslice_fortcode_rel_dir);
            mex_single ('./', './', 'avpix_df.F90')
            mex_single ('./', './', 'cut2d_df.F90')
            mex_single ('./', './', 'cut3d_df.F90')
            mex_single ('./', './', 'cut3dxye_df.F90')
            mex_single ('./', './', 'load_spe_df.F90')
            % mex_single (mslice_fortcode_rel_dir, mslice_mex_target_dir, 'ms_iris.f90')
            % mex_single (mslice_fortcode_rel_dir, mslice_mex_target_dir, 'put_spe_fortran.f90')
            mex_single ('./', './', 'slice_df.F90')
            mex_single ('./','./', 'spe2proj_df.F90')

			copy_files_list(pwd,mslice_mex_target_dir,mexext);
            delete(['./*.',mexext]);
            
            cd(mslice_extras_code_dir);
            mex_single ('./', './', 'slice_df_full.F')
            copyfile([mslice_extras_code_dir,filesep,'*.',mexext],mslice_mex_target_dir);
            delete(['./*.',mexext]);
            
            cd(start_dir);
         end            
    end

    if user_choise=='y'
        % Prompt for C compiler, and compile all C code    
        disp('!==================================================================!')
        disp('! please, select your C compiler ==================================!')
        mex -setup
    end
    if user_choise ~= 'f'
        cd(mslice_Ccode_dir);
        mex_single ('./', './', 'ffind.c')
        copyfile([mslice_Ccode_dir,filesep,'*.',mexext],mslice_mex_target_dir);
        delete(['./*.',mexext]);
    end
    
    cd(start_dir);
    display (' ')
    disp('!==================================================================!')
    disp('!  Succesfully created all required mex files =====================!')
    disp('!==================================================================!')    
    display(' ')
    
catch
    cd(start_dir);
    rethrow(lasterror)
end

%----------------------------------------------------------------
function mex_single (in_dir, out_dir, flname)
% mex a single file, with the input and output directories
% relative to the current directory
flname = fullfile(in_dir,flname);
outdir = fullfile(out_dir,'');
[f_path,f_name]=fileparts(flname);
targ_file=fullfile(f_path,[f_name,'.',mexext]);
if(exist(targ_file,'file'))
    try
        delete(targ_file)
    catch
        error([' file: ',f_name,mexext,' locked. deleteon error: ',lasterr()]);
    end
end

disp(['Mex file creation from ',flname,' ...'])
mex(flname,'-outdir', outdir);
