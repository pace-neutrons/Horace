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
herbert_mex_target_dir=fullfile(rootpath,'DLL',['_',computer]);
%  - mslice extras directory:
herbert_C_code_dir  =fullfile(rootpath,'_LowLevelCode','CPP');
herbert_F_code_dir  =fullfile(rootpath,'_LowLevelCode','Fortran');

try
    if user_choise ~= 'c'	
        set(herbert_config,'use_mex',false);      
        
        lib_dir = fullfile(herbert_F_code_dir,'mex');
        if ~exist(lib_dir,'dir')
            mkdir(lib_dir);
        end
        source_dir = fullfile(herbert_F_code_dir,'source');
        modules=cell(32,1);
        modules{1}=build_fortran_module(source_dir,lib_dir,'type_definitions.f90',lib_dir);     
        modules{2}=build_fortran_module(fullfile(source_dir,'tools'),lib_dir,'tools_parameters.f90',lib_dir);
        modules{3}=build_fortran_module(fullfile(source_dir,'tools'),lib_dir,'tools.f90',lib_dir);
        
        modules{4}=build_fortran_module(fullfile(source_dir,'file_io'),lib_dir,'cut_footer_info.f90',lib_dir);        
        modules{5}=build_fortran_module(fullfile(source_dir,'file_io'),lib_dir,'cut_pixel_info.f90',lib_dir);        
        modules{6}=build_fortran_module(fullfile(source_dir,'file_io'),lib_dir,'slice_footer_info.f90',lib_dir);        
        modules{7}=build_fortran_module(fullfile(source_dir,'file_io'),lib_dir,'slice_pixel_info.f90',lib_dir);      
        
        modules{8}=build_fortran_module(fullfile(source_dir,'maths'),lib_dir,'maths.f90',lib_dir);                        

        modules{9}=build_fortran_module(fullfile(source_dir,'file_io'),lib_dir,'cut_fortran_routines.f90',lib_dir);        
        modules{10}=build_fortran_module(fullfile(source_dir,'file_io'),lib_dir,'slice_fortran_routines.f90',lib_dir); 
        modules{11}=build_fortran_module(fullfile(source_dir,'tools'),lib_dir,'remark.f90',lib_dir);         
         
        
        % build objects:
        math_list={ 'bin_boundaries_get_xarr.f90',...
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
            modules{ic}=build_fortran_module(fullfile(source_dir,'maths'),lib_dir,math_list{i},lib_dir);
        end
        
        
        
        
        source_dir = herbert_F_code_dir;
        mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,...
                     'source_mex/bin_boundaries_from_descriptor.for',...
                     'source_mex_interface/IFL_bin_boundaries_get_marr.f90',...
                     'source_mex_interface/IFL_bin_boundaries_get_xarr.f90',...                                
                        modules{:});

        %mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,...
        %              'source_mex/get_cut_fortran.for',...
        %                modules{:});

        %mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,...
        %             'source_mex/get_slice_fortran.for',...
        %                modules{:});
       %put_cut_fortran.for
       %put_slice_fortran.for
      %put_spe_fortran.for
        
        
        mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,...
                     'source_mex/get_spe_fortran.for',...
                       modules{:});
                   
        mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,...
                     'source_mex/integrate_1d_points.for',...
                     'source_mex_interface/IFL_integrate_1d_points.f90',...
                      modules{:});

       mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,...
                     'source_mex/integrate_2d_x_points.for',...
                     'source_mex_interface/IFL_integrate_2d_x_points.f90',...
                      modules{:});                 
      mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,...
                     'source_mex/integrate_2d_y_points.for',...
                     'source_mex_interface/IFL_integrate_2d_y_points.f90',...
                      modules{:});
                  
      mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,...
                     'source_mex/integrate_3d_x_points.for',...
                     'source_mex_interface/IFL_integrate_3d_x_points.f90',...
                      modules{:});
      mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,...
                     'source_mex/integrate_3d_y_points.for',...
                     'source_mex_interface/IFL_integrate_3d_y_points.f90',...
                      modules{:});
                  
      mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,...
                     'source_mex/integrate_3d_z_points.for',...
                     'source_mex_interface/IFL_integrate_3d_z_points.f90',...
                      modules{:});

      mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,...
                     'source_mex/rebin_1d_hist.for',...
                     'source_mex_interface/IFL_rebin_1d_hist.f90',...
                      modules{:});
                  
      mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,...
                     'source_mex/rebin_2d_x_hist.for',...
                     'source_mex_interface/IFL_rebin_2d_x_hist.f90',...
                      modules{:});
      mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,...
                     'source_mex/rebin_2d_y_hist.for',...
                     'source_mex_interface/IFL_rebin_2d_y_hist.f90',...
                      modules{:});
      mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,...
                     'source_mex/rebin_3d_x_hist.for',...
                     'source_mex_interface/IFL_rebin_3d_x_hist.f90',...
                      modules{:});
      mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,...
                     'source_mex/rebin_3d_y_hist.for',...
                     'source_mex_interface/IFL_rebin_3d_y_hist.f90',...
                      modules{:});
      mex_single_f(source_dir,herbert_mex_target_dir,lib_dir,...
                     'source_mex/rebin_3d_z_hist.for',...
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
    rethrow(ex)
end

    
try
    if user_choise=='y'
        % Prompt for C compiler, and compile all C code    
        disp('!==================================================================!')
        disp('! please, select your C compiler ==================================!')
        mex -setup
    end
    if user_choise ~= 'f'
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
    rethrow(ex)
end
    


function   mex_single_f(in_dir,out_dir,lib_dir,varargin)
% build a single mex fortran routine from the list of files and objects
% provided in varargin 

if nargin<4
    error('MEX_SINGLE:invalid_argument','needs at least three arguments, but got %d',nargin)
end

files = cell(nargin-3,1);
ic=0;
for i=1:nargin-3
    if ~isempty(varargin{i})
        ic=ic+1;        
        files{ic} = make_filename(in_dir,varargin{i});
    end
end
files=files(1:ic);

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

disp(['==>Mex file creation from: ',f_name,' ...'])
%mex('-v','-outdir',outdir,files{:});
mex(['-I',lib_dir],'-outdir',outdir,files{:});



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

disp(['==>Mex file creation from: ',f_name,' ...'])
%mex('-v','-outdir',outdir,files{:});
mex('-outdir',outdir,files{:});


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


function obj_name=build_fortran_module(source_dir,target_dir,file_name,lib_dir)
[ps,base_name]=fileparts(file_name);
disp(['---> compiling module: ',base_name, ' started']);
file_name = make_filename(source_dir,file_name);
mex('-c',['-I',lib_dir],'-outdir',target_dir,file_name);
wkdir = pwd;
mod_name =[base_name,'.mod'];
if exist(mod_name,'file')
    movefile(fullfile(wkdir,mod_name),fullfile(target_dir,mod_name),'f');
end
if ispc
    obj_name=fullfile(target_dir,[base_name,'.obj']);
else
   obj_name=fullfile(target_dir,[base_name,'.o']);    
end
disp('---< finished ');

