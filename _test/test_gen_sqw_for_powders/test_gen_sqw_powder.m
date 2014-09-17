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
spe_dir = fileparts(mfilename('fullpath'));
spe_file=fullfile(spe_dir,'test_gen_sqw.nxspe');
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

if ~exist(spe_file,'file')   
    simulate_spe_testfunc (en, par_file, spe_file, @sqw_sc_hfm_testfunc, [ampl,SJ,gap,gamma,bkconst], scale,...
        efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs)
end
% clean up
sqw_pow_file=fullfile(tempdir,'test_pow_4to1.sqw');
spe_pow_file=fullfile(tempdir,'test_pow_rings.spe');
pow_par_file=fullfile(tempdir,'test_pow_rings.par');
pow_phx_file=fullfile(tempdir,'test_pow_rings.phx');
sqw_pow_rings_file=fullfile(tempdir,'test_pow_rings.sqw');
%
cleanup_obj=onCleanup(@()rm_files(sqw_pow_file,sqw_pow_rings_file,spe_pow_file,pow_par_file,pow_phx_file));

%--------------------------------------------------------------------------------------------------
% Perform a powder average in Horace
gen_sqw_powder_test (spe_file, par_file, sqw_pow_file, efix, emode);

% Create a simple powder file for Horace and mslice to compare with
[powmap,powpar]=powder_map(parObject(par_file),[3,0.2626,60],'squeeze');
save(powpar,pow_par_file)
save(phxObject(powpar),pow_phx_file)


ld=loaders_factory.instance().get_loader(spe_file);
data.filename='';
data.filepath='';
[data.S,data.ERR,data.en] = ld.load_data();
wspe=spe(data);

spe_pow=remap(wspe,powmap);
save(spe_pow,spe_pow_file)

% Create sqw file from the powder map
gen_sqw_powder_test (spe_pow_file, pow_par_file, sqw_pow_rings_file, efix, emode);


%--------------------------------------------------------------------------------------------------
% Visual inspection
% Plot the powder averaged sqw data
wpow=read_sqw(sqw_pow_file);

cuts_list= containers.Map();
cuts_list('w2') = @()cut_sqw(wpow,[0,0.03,7],0,'-nopix');
cuts_list('w1')=@()cut_sqw(wpow,[2,0.03,6.5],[53,57],'-nopix');

% plot(w2)
% lz 0 0.5
% dd(w1)

% Plot the same slice and cut from the sqw file created using the rings map
% Slightly different - as expected, because of the summing of a ring of pixels
% onto a single pixel in the rings map.
wpowrings=read_sqw(sqw_pow_rings_file);

% plot(w2rings)
% lz 0 0.5
% dd(w1rings)
cuts_list('w2rings') = @()cut_sqw(wpow,[0,0.03,7],0,'-nopix');
cuts_list('w1rings')=@()cut_sqw(wpowrings,[2,0.03,6.5],[53,57],'-nopix');


% % mslice:
% mslice_start
% mslice_load_data (spe_pow_file, pow_phx_file, efix, emode, 'S(Q,w)', '')
% % Now must do the rest manually. Agrees with the rings map data in Horace
%--------------------------------------------------------------------------------------------------

%--------------------------------------------------------------------------------------------------
log_level = get(hor_config,'horace_info_level');
sample_file=fullfile(rootpath,'test_gen_sqw_powder_output.mat');

if ~save_output
    % =====================================================================================================================
    % Compare with saved output
    % =====================================================================================================================
    tol=-3.0e-2;
    num_failed=check_sample_output(sample_file,tol,cuts_list,log_level);
    
    assertEqual(num_failed,0,' number of failed tests in test_gen_sqw_powder is more then 0');
    % Success announcement
    banner_to_screen([mfilename,': Test(s) passed'],'bot')
else
    % =====================================================================================================================
    % Save data
    % ======================================================================================================================
    save_sample_output(sample_file,cuts_list,log_level);
    
end
