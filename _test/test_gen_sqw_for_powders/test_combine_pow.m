function test_combine_pow(varargin)
% Test combining powder cylinder sqw files
%   >> test_combine_pow           % Compare with previously saved results in test_combine_pow_output.mat
%                                 % in the same folder as this function
%   >> test_combine_pow ('save')  % Save to test_combine_pow_output.mat in tempdir (type >> help tempdir
%                                 % for information about the system specific location returned by tempdir)
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
% Create spe files:
par_file=fullfile(common_data_dir,'map_4to1_dec09.par');
spe_file_1=fullfile(tempdir,'test_combine_pow_1.spe');
spe_file_2=fullfile(tempdir,'test_combine_pow_2.spe');

efix=100;
emode=1;
alatt=2*pi*[1,1,1];
angdeg=[90,90,90];
u=[1,0,0];
v=[0,1,0];
omega=0; dpsi=0; gl=0; gs=0;

% Simulate first file, with reproducible random looking noise
% -----------------------------------------------------------
en=-5:1:90;
psi_1=0;

simulate_spe_testfunc (en, par_file, spe_file_1, @sqw_cylinder, [10,1], 0.3,...
    efix, emode, alatt, angdeg, u, v, psi_1, omega, dpsi, gl, gs)


% Simulate second file, with reproducible random looking noise
% -------------------------------------------------------------
en=-9.5:2:95;
psi_2=30;

simulate_spe_testfunc (en, par_file, spe_file_2, @sqw_cylinder, [10,1], 0.3,...
    efix, emode, alatt, angdeg, u, v, psi_2, omega, dpsi, gl, gs)


% Create sqw files, combine and check results
% -------------------------------------------
sqw_file_1=fullfile(tempdir,'test_pow_1.sqw');
sqw_file_2=fullfile(tempdir,'test_pow_2.sqw');
sqw_file_tot=fullfile(tempdir,'test_pow_tot.sqw');

% clean up
cleanup_obj=onCleanup(@()rm_files(spe_file_1,spe_file_2,sqw_file_1,sqw_file_2,sqw_file_tot));

gen_sqw_powder_test (spe_file_1, par_file, sqw_file_1, efix, emode);
gen_sqw_powder_test (spe_file_2, par_file, sqw_file_2, efix, emode);
gen_sqw_powder_test ({spe_file_1,spe_file_2}, par_file, sqw_file_tot, efix, emode);

cuts_list= containers.Map();
cuts_list('w2_1') = @()cut_sqw(sqw_file_1,[0,0.05,8],0,'-nopix');
cuts_list('w2_2')=@()cut_sqw(sqw_file_2,[0,0.05,8],0,'-nopix');
cuts_list('w2_tot')=@()cut_sqw(sqw_file_tot,[0,0.05,8],0,'-nopix');

cuts_list('w1_1')=@()cut_sqw(sqw_file_1,[0,0.05,3],[40,50],'-nopix');
cuts_list('w1_2')=@()cut_sqw(sqw_file_2,[0,0.05,3],[40,50],'-nopix');
cuts_list('w1_tot')=@()cut_sqw(sqw_file_tot,[0,0.05,3],[40,50],'-nopix');


%--------------------------------------------------------------------------------------------------
log_level = get(hor_config,'horace_info_level');
output_file=fullfile(rootpath,'test_combine_pow_output.mat');
if ~save_output
    % =====================================================================================================================
    % Compare with saved output
    % ======================================================================================================================
    tol=0.0002; % BAD
    num_failed=check_sample_output(output_file,tol,cuts_list,log_level);
    
    assertEqual(num_failed,0,' One or more tests in test_combibe_pow failed');
    % Success announcement
    banner_to_screen([mfilename,': Test(s) passed'],'bot')
else
    % =====================================================================================================================
    % Save data
    % ======================================================================================================================    
    save_sample_output(output_file,cuts_list,log_level);    
end



