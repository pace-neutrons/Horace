function test_combine_cyl(varargin)
% Test combining powder cylinder sqw files
%   >> test_combine_cyl           % Compare with previously saved results in test_combine_cyl_output.mat
%                                 % in the same folder as this function
%   >> test_combine_cyl ('save')  % Save to test_combine_cyl_output.mat in tempdir (type >> help tempdir
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
spe_file_1=fullfile(tempdir,'test_combine_cyl_1.spe');
spe_file_2=fullfile(tempdir,'test_combine_cyl_2.spe');

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
sqw_file_1=fullfile(tempdir,'test_cyl_1.sqw');
sqw_file_2=fullfile(tempdir,'test_cyl_2.sqw');
sqw_file_tot=fullfile(tempdir,'test_cyl_tot.sqw');

gen_sqw_cylinder_test (spe_file_1, par_file, sqw_file_1, efix, emode, alatt(3), psi_1, 90, 0);
gen_sqw_cylinder_test (spe_file_2, par_file, sqw_file_2, efix, emode, alatt(3), psi_2, 90, 0);
gen_sqw_cylinder_test ({spe_file_1,spe_file_2}, par_file, sqw_file_tot, efix, emode, alatt(3), [psi_1,psi_2], 90, 0);

w2_1=cut_sqw(sqw_file_1,0.1,0.1,[40,50],'-nopix');
w2_2=cut_sqw(sqw_file_2,0.1,0.1,[40,50],'-nopix');
w2_tot=cut_sqw(sqw_file_tot,0.1,0.1,[40,50],'-nopix');

w1_1=cut_sqw(sqw_file_1,[0,0.1,3],[2.2,2.5],[40,50],'-nopix');
w1_2=cut_sqw(sqw_file_2,[0,0.1,3],[2.2,2.5],[40,50],'-nopix');
w1_tot=cut_sqw(sqw_file_tot,[0,0.1,3],[2.2,2.5],[40,50],'-nopix');

%--------------------------------------------------------------------------------------------------
% Visually inspect
% acolor k
% dd(w1_1)
% acolor b
% pd(w1_2)
% acolor r
% pd(w1_tot)  % does not overlay - but that is OK
%--------------------------------------------------------------------------------------------------

%--------------------------------------------------------------------------------------------------
% Cleanup
try
    delete(spe_file_1)
    delete(spe_file_2)
    delete(sqw_file_1)
    delete(sqw_file_2)
    delete(sqw_file_tot)
catch
    disp('Unable to delete temporary file(s)')
end

% =====================================================================================================================
% Compare with saved output
% ====================================================================================================================== 
if ~save_output
    disp('====================================')
    disp('    Comparing with saved output')
    disp('====================================')
    output_file=fullfile(rootpath,'test_combine_cyl_output.mat');
    old=load(output_file);
    nam=fieldnames(old);
    tol=-1.0e-13;
    for i=1:numel(nam)
        [ok,mess]=equal_to_tol(eval(nam{i}),  old.(nam{i}), tol, 'ignore_str', 1); if ~ok, assertTrue(false,['[',nam{i},']',mess]), end
    end
    % Success announcement
    banner_to_screen([mfilename,': Test(s) passed'],'bot')
end


% =====================================================================================================================
% Save data
% ====================================================================================================================== 
if save_output
    disp('===========================')
    disp('    Save output')
    disp('===========================')
    
    output_file=fullfile(tempdir,'test_combine_cyl_output.mat');
    save(output_file, 'w2_1', 'w2_2', 'w2_tot', 'w1_1', 'w1_2', 'w1_tot')
    
    disp(' ')
    disp(['Output saved to ',output_file])
    disp(' ')
end
