function test_gen_sqw_powder(varargin)
% Test powder sqw file
%   >> test_gen_sqw_powder           % Compare with previously saved results in test_gen_sqw_powder_output.mat
%                                    % in the same folder as this function
%   >> test_gen_sqw_powder ('save')  % Save to test_gen_sqw_powder_output.mat in tempdir (type >> help tempdir
%                                    % for information about the system specific location returned by tempdir)
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
spe_file=fullfile(tempdir,'test_gen_sqw_powder.spe');
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
% Perform a powder average in Horace
sqw_pow_file=fullfile(tempdir,'test_pow_4to1.sqw');
gen_sqw_powder_test (spe_file, par_file, sqw_pow_file, efix, emode);

% Create a simple powder file for Horace and mslice to compare with
spe_pow_file=fullfile(tempdir,'test_pow_rings.spe');
pow_par_file=fullfile(tempdir,'test_pow_rings.par');
pow_phx_file=fullfile(tempdir,'test_pow_rings.phx');

[powmap,powpar]=powder_map(parObject(par_file),[3,0.2626,60],'squeeze');
save(powpar,pow_par_file)
save(phxObject(powpar),pow_phx_file)

wspe=read(spe,spe_file);
spe_pow=remap(wspe,powmap);
save(spe_pow,spe_pow_file)

% Create sqw file from the powder map
sqw_pow_rings_file=fullfile(tempdir,'test_pow_rings.sqw');
gen_sqw_powder_test (spe_pow_file, pow_par_file, sqw_pow_rings_file, efix, emode);

%--------------------------------------------------------------------------------------------------
% Visual inspection
% Plot the powder averaged sqw data
wpow=read_sqw(sqw_pow_file);
w2=cut_sqw(wpow,[0,0.03,7],0,'-nopix');
% plot(w2)
% lz 0 0.5
w1=cut_sqw(wpow,[2,0.03,6.5],[53,57],'-nopix');
% dd(w1)

% Plot the same slice and cut from the sqw file created using the rings map
% Slightly different - as expected, because of the summing of a ring of pixels
% onto a single pixel in the rings map.
wpowrings=read_sqw(sqw_pow_rings_file);
w2rings=cut_sqw(wpowrings,[0,0.03,7],0,'-nopix');
% plot(w2rings)
% lz 0 0.5
w1rings=cut_sqw(wpowrings,[2,0.03,6.5],[53,57],'-nopix');
% dd(w1rings)

% % mslice:
% mslice_start
% mslice_load_data (spe_pow_file, pow_phx_file, efix, emode, 'S(Q,w)', '')
% % Now must do the rest manually. Agrees with the rings map data in Horace
%--------------------------------------------------------------------------------------------------

%--------------------------------------------------------------------------------------------------
% Cleanup
try
    delete(spe_file)
    delete(sqw_pow_file)
    delete(sqw_pow_rings_file)
    delete(spe_pow_file)
    delete(pow_par_file)
    delete(pow_phx_file)
catch
    disp('Unable to delete temporary file(s)')
end
log_level = get(hor_config,'horace_info_level');
% =====================================================================================================================
% Compare with saved output
% ======================================================================================================================
if ~save_output
    if log_level>-1
        disp('====================================')
        disp('    Comparing with saved output')
        disp('====================================')
    end
    output_file=fullfile(rootpath,'test_gen_sqw_powder_output.mat');
    old=load(output_file);
    nam=fieldnames(old);
    tol=1.0e-5;
    for i=1:numel(nam)
        [ok,mess]=equal_to_tol(eval(nam{i}),  old.(nam{i}), tol, 'ignore_str', 1);
        assertTrue(ok,['[',nam{i},']',mess])
    end
    % Success announcement
    banner_to_screen([mfilename,': Test(s) passed'],'bot')
end


% =====================================================================================================================
% Save data
% ======================================================================================================================
if save_output
    if log_level>-1
        disp('===========================')
        disp('    Save output')
        disp('===========================')
    end
    
    output_file=fullfile(tempdir,'test_gen_sqw_powder_output.mat');
    save(output_file, 'w1', 'w2', 'w1rings', 'w2rings')
    
    if log_level>-1
        disp(' ')
        disp(['Output saved to ',output_file])
        disp(' ')
    end
end
