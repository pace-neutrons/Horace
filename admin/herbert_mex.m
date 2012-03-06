function herbert_mex(varargin)
% Create mex files for all the herbert fortran and C++ routines
%
%>> herbert_mex       -- this should automatically produce the mex files
%                        for herbert
%>> herbert_mex options -- modify build options for herbert (convenience)
%
% Availible options:
% -noprompt  -- do not ask to configure FORTRAN and C compiler, default ask
%               if provided, assume that compiler is configured and we are
%               building both fortran and C parts of code
% -CPP    -- assume compiler configured to build C -part of code, build C;
% -FOR    -- assume compiler configured to build FORTRAN -part of code, build FORTRAN;
% -keep_lib  -- keep the intermediate fortran library 
% -use_lib   -- use the previously build library when building the mex-code (missing
%               library components will be added, will also invoke -keep_lib 
% -missing   -- build only missing mex files, if not present, script
%               rebuilds all existing files
%
%   $Rev$ ($Date$)
%
% root directory is assumed to be that in which mslice_init resides
% list of keys the sctip accepts
keys={'-noprompt','-CPP','-FOR','-use_lib','-keep_lib','-missing'};
%defaults:
prompt4compiler=true;
keep_lib       =false;
use_lib        =false;
missing        ='';


if nargin >0
    ikeys  = ismember(varargin,keys);    
    if ~all(ikeys)
        noKeys = varargin(~ikeys);
        for i=1:numel(noKeys)
            disp(['HERBERT_MEX: unrecognized key: ',noKeys{i},' ignored']);
        end
    end
    theKeys = varargin(ikeys);
    if ismember('-noprompt',theKeys)
        prompt4compiler=false;
        user_choice='n';            
    end
    if ismember('-CPP',theKeys)
        prompt4compiler=false;
        user_choice    = 'c';
    end
    if ismember('-FOR',theKeys)
        prompt4compiler=false;
        user_choice    = 'f';
    end
    if ismember('-keep_lib',theKeys)
       keep_lib    = true;
    end
    if ismember('-use_lib',theKeys)
        use_lib     = true;
        keep_lib    =true;        
    end 
    if ismember('-missing',theKeys)
        missing = '-missing';
    end
end

rootpath = fileparts(which('herbert_init'));


% -----------------------------------------------------
if prompt4compiler
    user_choice = ask4Compiler();
    if user_choice=='e'
        return;
    end
end

if user_choice=='y'
    % Prompt for fortran compiler
    disp('!==================================================================!')
    disp('! please, select your FORTRAN compiler  ===========================!')
    mex -setup
end
% Source code directories, and output directories:
%  - herbert target directrory:
herbert_mex_target_dir=fullfile(rootpath,'DLL',['_',computer],matlab_version_folder());
if ~exist(herbert_mex_target_dir,'dir')
    mkdir(herbert_mex_target_dir);
end
%  - mslice extras directory:
herbert_C_code_dir  =fullfile(rootpath,'_LowLevelCode','CPP');
herbert_F_code_dir  =fullfile(rootpath,'_LowLevelCode','Fortran');
lib_dir             =fullfile(herbert_F_code_dir,'mex');
try
    if user_choice ~= 'c'	
        set(herbert_config,'use_mex',false);      
               
        if ~exist(lib_dir,'dir')
            mkdir(lib_dir);
        end
% --> BUILD FORTRAN MEX FILES LIBRARY:                
        source_dir = fullfile(herbert_F_code_dir,'source');
        modules=cell(33,1);
        modules{1}=build_fortran_module(source_dir,lib_dir,'type_definitions.f90',lib_dir,use_lib);     
        modules{2}=build_fortran_module(fullfile(source_dir,'tools'),lib_dir,'tools_parameters.f90',lib_dir,use_lib);
        modules{3}=build_fortran_module(fullfile(source_dir,'tools'),lib_dir,'tools.f90',lib_dir,use_lib);
        
        modules{4}=build_fortran_module(fullfile(source_dir,'file_io'),lib_dir,'cut_footer_info.f90',lib_dir,use_lib);        
        modules{5}=build_fortran_module(fullfile(source_dir,'file_io'),lib_dir,'cut_pixel_info.f90',lib_dir,use_lib);        
        modules{6}=build_fortran_module(fullfile(source_dir,'file_io'),lib_dir,'slice_footer_info.f90',lib_dir,use_lib);        
        modules{7}=build_fortran_module(fullfile(source_dir,'file_io'),lib_dir,'slice_pixel_info.f90',lib_dir,use_lib);      
        
        modules{8}=build_fortran_module(fullfile(source_dir,'maths'),lib_dir,'I_maths.f90',lib_dir,use_lib);                        

        modules{9}=build_fortran_module(fullfile(source_dir,'file_io'),lib_dir,'cut_fortran_routines.f90',lib_dir,use_lib);        
        modules{10}=build_fortran_module(fullfile(source_dir,'file_io'),lib_dir,'slice_fortran_routines.f90',lib_dir,use_lib); 
        modules{11}=build_fortran_module(fullfile(source_dir,'tools'),lib_dir,'remark.f90',lib_dir,use_lib);         
         
        
        % build objects:
        math_list={ 'I_Index.f90','bin_boundaries_get_xarr.f90',...
                    'upper_index.f90',                 'lower_index.f90',                 'integrate_1d_points.f90',...
                    'integrate_2d_x_points.f90',       'integrate_2d_y_points.f90',       'integrate_3d_x_points.f90',...
                    'integrate_3d_y_points.f90',       'integrate_3d_z_points.f90',...
                    'rebin_1d_hist.f90',               'rebin_2d_x_hist.f90',             'rebin_2d_y_hist.f90',...
                    'rebin_3d_x_hist.f90',             'rebin_3d_y_hist.f90',             'rebin_3d_z_hist.f90',...
                    'single_integrate_1d_points.f90',  'single_integrate_2d_x_points.f90','single_integrate_2d_y_points.f90',...
                    'single_integrate_3d_x_points.f90','single_integrate_3d_y_points.f90','single_integrate_3d_z_points.f90'};

        ic = 11;
        for i=1:numel(math_list)
            ic=ic+1;            
            modules{ic}=build_fortran_module(fullfile(source_dir,'maths'),lib_dir,math_list{i},lib_dir,use_lib);
        end
        
% --> BUILD ACTUAL MEX FILES:                      
        source_dir = herbert_F_code_dir;

        mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,missing,...
                      'source_mex/get_cut_fortran.FOR',...
                        modules{:});

        mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,missing,...
                     'source_mex/get_slice_fortran.FOR',...
                        modules{:});
                    
        mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,missing,...
                     'source_mex/put_cut_fortran.FOR',...
                       modules{:});

        
        mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,missing,...
                     'source_mex/put_slice_fortran.FOR',...
                       modules{:});
         
        mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,missing,...
                     'source_mex/put_spe_fortran.FOR',...
                       modules{:});

        
        mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,missing,...
                     'source_mex/get_spe_fortran.FOR',...
                       modules{:});
                   
      % templated generated routines which have matlab equivalent         
        mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,missing,...
                     '-o','bin_boundaries_from_descriptor_mex',...          
                     'source_mex/bin_boundaries_from_descriptor.FOR',...
                     'source_mex_interface/IFL_bin_boundaries_get_marr.f90',...
                     'source_mex_interface/IFL_bin_boundaries_get_xarr.f90',...                                
                        modules{:});

      
        mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,missing,...
                     '-o','integrate_1d_points_mex',...            
                     'source_mex/integrate_1d_points.FOR',...
                     'source_mex_interface/IFL_integrate_1d_points.f90',...
                      modules{:});

       mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,missing,...
                     '-o','integrate_2d_x_points_mex',...                       
                     'source_mex/integrate_2d_x_points.FOR',...
                     'source_mex_interface/IFL_integrate_2d_x_points.f90',...
                      modules{:});                 
      mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,missing,...
                     '-o','integrate_2d_y_points_mex',...                       
                     'source_mex/integrate_2d_y_points.FOR',...
                     'source_mex_interface/IFL_integrate_2d_y_points.f90',...
                      modules{:});
                  
      mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,missing,...
                     '-o','integrate_3d_x_points_mex',...                                 
                     'source_mex/integrate_3d_x_points.FOR',...
                     'source_mex_interface/IFL_integrate_3d_x_points.f90',...
                      modules{:});
      mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,missing,...
                     '-o','integrate_3d_y_points_mex',...                                           
                     'source_mex/integrate_3d_y_points.FOR',...
                     'source_mex_interface/IFL_integrate_3d_y_points.f90',...
                      modules{:});
                  
      mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,missing,...
                     '-o','integrate_3d_z_points_mex',...                                                     
                     'source_mex/integrate_3d_z_points.FOR',...
                     'source_mex_interface/IFL_integrate_3d_z_points.f90',...
                      modules{:});

      mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,missing,...         
                     '-o','rebin_1d_hist_mex',...
                     'source_mex/rebin_1d_hist.FOR',...
                     'source_mex_interface/IFL_rebin_1d_hist.f90',...
                      modules{:});                  
      mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,missing,...
                     '-o','rebin_2d_x_hist_mex',...          
                     'source_mex/rebin_2d_x_hist.FOR',...
                     'source_mex_interface/IFL_rebin_2d_x_hist.f90',...
                      modules{:});
      mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,missing,...
                     '-o','rebin_2d_y_hist_mex',...                    
                     'source_mex/rebin_2d_y_hist.FOR',...
                     'source_mex_interface/IFL_rebin_2d_y_hist.f90',...
                      modules{:});
      mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,missing,...
                     '-o','rebin_3d_x_hist_mex',...                              
                     'source_mex/rebin_3d_x_hist.FOR',...
                     'source_mex_interface/IFL_rebin_3d_x_hist.f90',...
                      modules{:});
      mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,missing,...
                     '-o','rebin_3d_y_hist_mex',...                                        
                     'source_mex/rebin_3d_y_hist.FOR',...
                     'source_mex_interface/IFL_rebin_3d_y_hist.f90',...
                      modules{:});
      mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,missing,...
                     '-o','rebin_3d_z_hist_mex',...                                                  
                     'source_mex/rebin_3d_z_hist.FOR',...
                     'source_mex_interface/IFL_rebin_3d_z_hist.f90',...
                      modules{:});

                    
       set(herbert_config,'use_mex',true);	               
       display (' ')
       disp('!==================================================================!')
       disp('!  Succesfully created required FORTRAN mex files  ================!')
       disp('!==================================================================!')    
       display(' ')
       
    end            
catch ex
     set(herbert_config,'use_mex',false);
     display (' ')
     disp('!==================================================================!')
     disp('!  FORTRAN mex-ing failed                          ================!')
     disp('!==================================================================!') 
     display(' ')
     keep_lib = true;
     if user_choice=='f'
         rethrow(ex);
     else
        disp(ex);
     end
end

    
try
    if user_choice=='y'
        % Prompt for C compiler, and compile all C code    
        disp('!==================================================================!')
        disp('! please, select your C compiler ==================================!')
        mex -setup
    end
    if user_choice ~= 'f'
        set(herbert_config,'use_mex_C',false);
        % build C++ files
        mex_single_c(fullfile(herbert_C_code_dir,'get_ascii_file'), herbert_mex_target_dir,...
                    'get_ascii_file.cpp','IIget_ascii_file.cpp')
                
        set(herbert_config,'use_mex_C',true);
        display (' ')
        disp('!==================================================================!')
        disp('!  Succesfully created required C mex files   =====================!')
        disp('!==================================================================!')    
        display(' ')
        
    end
    
 
catch ex
     display (' ')
     disp('!==================================================================!')
     disp('!  C mex-ing failed                                ================!')
     disp('!==================================================================!')    
     display(' ')
     set(herbert_config,'use_mex_C',false);    
     rethrow(ex)
end

if ~keep_lib 
    rmdir(lib_dir,'s');
end
    


function   mex_single_f(in_dir,out_dir,lib_dir,varargin)
% build a single mex fortran routine from the list of files and objects
% provided in varargin 
%
%  -o      if switch is selected, the string, which follows to the
%          switch defines the name of the target mex file.
% -missing if switch is present, routine will build only missing mex files
%          it will rebuild exisign mex files otherwise
%


if nargin<4
    error('MEX_SINGLE:invalid_argument','needs at least three arguments, but got %d',nargin)
end
outdir = fullfile(out_dir,'');
% remove empty fields
argi = varargin(~ismember(varargin,''));
% PROCESSING INPUT KEYS
% do we want build all mex files or just the missing one.
rebuild_mex=true;
if ismember('-missing',argi)
    rebuild_mex=false;
    argi = argi(~ismember(argi,'-missing'));
end

% if target file name is different from the mex file name, choose the file name requested;
if ismember('-o',argi )
    nofile = ismember(argi,'-o');
    ind    = find(nofile);
    if numel(ind) > 1
        error('MEX_SINGLE:invalid_argument',' more then 1 -o option find in input arguments');
    end
    [f_path,f_name]=fileparts(argi{ind+1});   
    % this is not a source file but the target file name
    nofile(ind+1) = true;
    target_fname = [f_name,'.',mexext];    
    files  = argi (~nofile);        
else
    files  = argi;
    [f_path,f_name]=fileparts(files{1});
    % identify target file name
    target_fname = [f_name,'.',mexext];
end

% strip possible empty cells
ic=0;
for i=1:numel(files)
    if ~isempty(files{i})
        ic=ic+1;        
        files{ic} = make_filename(in_dir,files{i});
    end
end
files=files(1:ic);


targ_file=fullfile(outdir,target_fname);    
if exist(targ_file,'file')
    if rebuild_mex
        try
            delete(targ_file)
        catch
            cd(old_path);
            error([' file: ',f_name,mexext,' locked. deleteon error: ',lasterr()]);
        end
    else
        return;
    end
end

fprintf('%s',['===>Mex file creation from: ',f_name,' ...'])
%mex('-v','-outdir',outdir,files{:});
mex(['-I',lib_dir],'-outdir',outdir,'-output',target_fname,files{:});
disp(' <=== completed');



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


function fname=make_filename(in_dir,str)
if exist(str,'file')
    fname=str;
    return;
end
[fp,filename,fext] = fileparts(str);
fname=fullfile(in_dir,fp,[filename,fext]);       
if ~exist(fname,'file')
    error('HERBERT_MEX:invalid_argument','file: %s expected to be compiled but does not exist',fname);
end


function obj_name=build_fortran_module(source_dir,target_dir,file_name,lib_dir,use_lib)
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
mex('-c',['-I',lib_dir],'-outdir',target_dir,file_name);
wkdir = pwd;
mod_name =[base_name,'.mod'];
if exist(mod_name,'file')
    movefile(fullfile(wkdir,mod_name),fullfile(target_dir,mod_name),'f');
end
disp('---< completed');

function user_choice = ask4Compiler()
disp('!==================================================================!')
disp('! Would you like to select your compilers (win) or have configured !')
disp('! your compiler yourself?:  y/n/c/f/e                              !')
disp('! y-select and configure;  n - already configured                  !')
disp('! c or f allow you to build C or FORTRAN part of the program       !')
disp('!        having configured proper compiler yourself                !')
disp('! e (end)-- cancel script execution                                !')
disp('!------------------------------------------------------------------!')
disp('!------------------------------------------------------------------!')
disp('! e -- cancel (end)                                                !')
user_entry=input('! y/n/c/f/e :','s');
user_entry=strtrim(lower(user_entry));
user_choice = user_entry(1);
disp(['!===> ' user_choice,' choosen                                                    !']);
disp('!==================================================================!')
if ~(user_choice=='y'||user_choice=='n'||user_choice=='c'||user_choice=='f')
    user_choice='e';
end
if user_choice=='e'
    disp('!  canceled                                                        !')        
    disp('!==================================================================!')    
    return;
end
