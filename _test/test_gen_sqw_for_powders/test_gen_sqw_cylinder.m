function test_gen_sqw_cylinder(varargin)
% Test cylinder sqw file
%   >> test_gen_sqw_cylinder           % Compare with previously saved results in test_gen_sqw_cylinder_output.mat
%                                      % in the same folder as this function
%   >> test_gen_sqw_cylinder ('save')  % Save to test_gen_sqw_cylinder_output.mat in tempdir (type >> help tempdir
%                                      % for information about the system specific location returned by tempdir)
%
% Author: T.G.Perring

banner_to_screen(mfilename)

% Check input argument
if nargin==1
    if ischar(varargin{1}) && size(varargin{1},1)==1 && isequal(lower(varargin{1}),'save')
        save_output=true;
    else
        error('Unrecognised option')
    end
elseif nargin==0
    save_output=false;
else
    error('Check number of input arguments')
end

% -----------------------------------------------------------------------------
% Add common functions folder to path, and get location of common data
addpath(fullfile(fileparts(which('horace_init')),'_test','common_functions'))
common_data_dir=fullfile(fileparts(which('horace_init')),'_test','common_data');
% -----------------------------------------------------------------------------
% Set up paths:
rootpath=fileparts(mfilename('fullpath'));

% =====================================================================================================================
% Create sqw file:
en=0:1:90;
par_file=fullfile(common_data_dir,'map_4to1_dec09.par');
spe_file=fullfile(tempdir,'test_gen_sqw_cylinder.spe');
efix=100;
emode=1;
alatt=[5,5,5];
angdeg=[90,90,90];
u=[1,1,0];
v=[0,0,1];
psi=20;
omega=0; dpsi=0; gl=0; gs=0;

ampl=10; SJ=8; gap=5; gamma=5; bkconst=0;
scale=0.1;
simulate_spe_testfunc (en, par_file, spe_file, @sqw_sc_hfm_testfunc, [ampl,SJ,gap,gamma,bkconst], scale,...
    efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs)


%--------------------------------------------------------------------------------------------------
% Perform a cylinder average in Horace
sqw_cyl_file=fullfile(tempdir,'test_cyl_4to1.sqw');
gen_sqw_cylinder_test (spe_file, par_file, sqw_cyl_file, efix, emode, 1.5, 0, 0, 0);

% clean up
cleanup_obj=onCleanup(@()rm_files(spe_file,sqw_cyl_file));

%--------------------------------------------------------------------------------------------------
% Visual inspection
% Plot the cylinder averaged sqw data
wcyl=read_sqw(sqw_cyl_file);

cuts_list= containers.Map();
cuts_list('w2') = @()cut_sqw(wcyl,[4,0.03,6],[-0.15,0.35],0,'-nopix');
cuts_list('w1')=@()cut_sqw(wcyl,[2,0.03,6.5],[-0.7,0.2],[53,57],'-nopix');

% dd(w1)
%--------------------------------------------------------------------------------------------------

%--------------------------------------------------------------------------------------------------
% Cleanup
try
    delete(spe_file)
    delete(sqw_cyl_file)
catch
    disp('Unable to delete temporary file(s)')
end

log_level = get(hor_config,'horace_info_level');
sample_file=fullfile(rootpath,'test_gen_sqw_cylinder_output.mat');
if ~save_output
    % =====================================================================================================================
    % Compare with saved output
    % =====================================================================================================================    
    tol=-1.0e-13;
    num_failed=check_sample_output(sample_file,tol,cuts_list,log_level);
    
    assertEqual(num_failed,0,' One or more tests in test_gen_sqw_cylinder failed');
    % Success announcement
    banner_to_screen([mfilename,': Test(s) passed'],'bot')
else
    % =====================================================================================================================
    % Save data
    % ======================================================================================================================
    save_sample_output(sample_file,cuts_list,log_level);
end

