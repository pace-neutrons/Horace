function test_gen_sqw_accumulate_sqw (varargin)
% Series of tests of gen_sqw and associated functions
% Optionally writes results to output file
%
%   >> test_gen_sqw_accumulate_sqw          % Compares with previously saved results in test_gen_sqw_accumulate_sqw_output.mat
%                                           % in the same folder as this function
%   >> test_gen_sqw_accumulate_sqw ('save') % Save to test_multifit_horace_1_output.mat
%
% Reads previously created test data sets.

banner_to_screen(mfilename)

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

demo_dir=fileparts(mfilename('fullpath'));
outdir=tempdir;     % directory of spe and tmp files

nfiles_max=6;

%% =====================================================================================================================
% Make instrument and sample
% =====================================================================================================================
wmod=IX_moderator('AP2',12,35,'ikcarp',[3,25,0.3],'',[],0.12,0.12,0.05,300);
wap=IX_aperture(-2,0.067,0.067);
wchop=IX_fermi_chopper(1.8,600,0.1,1.3,0.003);
instrument_ref.moderator=wmod;
instrument_ref.aperture=wap;
instrument_ref.fermi_chopper=wchop;
sample_ref=IX_sample('PCSMO',true,[1,1,0],[0,0,1],'cuboid',[0.04,0.05,0.02],1.6,300);

instrument=repmat(instrument_ref,1,nfiles_max);
for i=1:numel(instrument)
    instrument(i).IX_fermi_chopper.frequency=100*i;
end

sample_1=sample_ref;
sample_2=sample_ref;
sample_2.temperature=350;


%% =====================================================================================================================
% Make spe files
% =====================================================================================================================
par_file=fullfile('96dets.par');
spe_file=cell(1,nfiles_max);
for i=1:nfiles_max
    spe_file{i}=[outdir,'spe_',num2str(i),'.spe'];
end

en=cell(1,nfiles_max);
efix=zeros(1,nfiles_max);
psi=zeros(1,nfiles_max);
omega=zeros(1,nfiles_max);
dpsi=zeros(1,nfiles_max);
gl=zeros(1,nfiles_max);
gs=zeros(1,nfiles_max);
for i=1:nfiles_max
    efix(i)=35+0.5*i;                       % different ei for each file
    en{i}=0.05*efix(i):0.2+i/50:0.95*efix(i);  % different energy bins for each file
    psi(i)=90-i+1;
    omega(i)=10+i/2;
    dpsi(i)=0.1+i/10;
    gl(i)=3-i/6;
    gs(i)=2.4+i/7;
end
psi=90:-1:90-nfiles_max+1;

emode=1;
alatt=[4.4,5.5,6.6];
angdeg=[100,105,110];
u=[1.02,0.99,0.02];
v=[0.025,-0.01,1.04];

pars=[1000,8,2,4,0];  % [Seff,SJ,gap,gamma,bkconst]
scale=0.3;
for i=1:nfiles_max
    simulate_spe_testfunc (en{i}, par_file, spe_file{i}, @sqw_sc_hfm_testfunc, pars, scale,...
        efix(i), emode, alatt, angdeg, u, v, psi(i), omega(i), dpsi(i), gl(i), gs(i));
end


%% ---------------------------------------
% Test gen_sqw
% ---------------------------------------
sqw_file=cell(1,nfiles_max);
for i=1:nfiles_max
    sqw_file{i}=fullfile(outdir,['sqw_',num2str(i),'.sqw']);                   % output sqw file
    gen_sqw (spe_file(i), par_file, sqw_file{i}, efix(i), emode, alatt, angdeg, u, v, psi(i), omega(i), dpsi(i), gl(i), gs(i),[3,3,3,3]);
end

sqw_file_123456=fullfile(outdir,'sqw_123456.sqw');                   % output sqw file
[dummy,grid,urange]=gen_sqw (spe_file, par_file, sqw_file_123456, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);

sqw_file_145623=fullfile(outdir,'sqw_145623.sqw');                   % output sqw file
[dummy,grid,urange]=gen_sqw (spe_file([1,4,5,6,2,3]), par_file, sqw_file_145623, efix([1,4,5,6,2,3]), emode, alatt, angdeg, u, v, psi([1,4,5,6,2,3]), omega([1,4,5,6,2,3]), dpsi([1,4,5,6,2,3]), gl([1,4,5,6,2,3]), gs([1,4,5,6,2,3]));


% Make some cuts:
% ---------------
proj.u=[1,0,0.1]; proj.v=[0,0,1];

% Check cuts from each sqw individually, and the single combined sqw file are the same
[ok,mess,w1a,w1ref]=is_cut_equal(sqw_file_123456,sqw_file,proj,[-1.5,0.025,0],[-2.1,-1.9],[-0.5,0.5],[-Inf,Inf]);
if ~ok, assertTrue(false,'Combining cuts from each individual sqw file and the cut from the combined sqw file not the same'), end

% Check cuts from gen_sqw output with spe files in a different order are the same
[ok,mess,dummy_w1,w1b]=is_cut_equal(sqw_file_123456,sqw_file_145623,proj,[-1.5,0.025,0],[-2.1,-1.9],[-0.5,0.5],[-Inf,Inf]);
if ~ok, assertTrue(false,'Cuts from gen_sqw output with spe files in a different order are not the same'), end



%% ---------------------------------------
% Test accumulate_sqw
% ---------------------------------------

% Create some sqw files against which to compare the output of accumulate_sqw
% ---------------------------------------------------------------------------
sqw_file_14=fullfile(outdir,'sqw_14.sqw');                   % output sqw file
[dummy,grid,urange]=gen_sqw (spe_file([1,4]), par_file, sqw_file_14, efix([1,4]), emode, alatt, angdeg, u, v, psi([1,4]), omega([1,4]), dpsi([1,4]), gl([1,4]), gs([1,4]));

sqw_file_1456=fullfile(outdir,'sqw_1456.sqw');                   % output sqw file
[dummy,grid,urange]=gen_sqw (spe_file([1,4,5,6]), par_file, sqw_file_1456, efix([1,4,5,6]), emode, alatt, angdeg, u, v, psi([1,4,5,6]), omega([1,4,5,6]), dpsi([1,4,5,6]), gl([1,4,5,6]), gs([1,4,5,6]));

sqw_file_15456=fullfile(outdir,'sqw_15456.sqw');                   % output sqw file
try
    [dummy,grid,urange]=gen_sqw (spe_file([1,5,4,5,6]), par_file, sqw_file_15456, efix([1,5,4,5,6]), emode, alatt, angdeg, u, v, psi([1,5,4,5,6]), omega([1,5,4,5,6]), dpsi([1,5,4,5,6]), gl([1,5,4,5,6]), gs([1,5,4,5,6]), 'replicate');
    ok=false;
catch
    ok=true;
end
if ~ok, assertTrue(false,'Should have failed because of repeated spe file name and parameters'), end

sqw_file_11456=fullfile(outdir,'sqw_11456.sqw');                   % output sqw file
[dummy,grid,urange]=gen_sqw (spe_file([1,1,4,5,6]), par_file, sqw_file_11456, efix([1,3,4,5,6]), emode, alatt, angdeg, u, v, psi([1,3,4,5,6]), omega([1,3,4,5,6]), dpsi([1,3,4,5,6]), gl([1,3,4,5,6]), gs([1,3,4,5,6]), 'replicate');

    
% Now use accumulate sqw
% ----------------------
sqw_file_accum=fullfile(outdir,'sqw_accum.sqw');

spe_accum={spe_file{1},'','',spe_file{4},'',''};
accumulate_sqw (spe_accum, par_file, sqw_file_accum, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, 'clean');
[ok,mess,w2_14]=is_cut_equal(sqw_file_14,sqw_file_accum,proj,[-1.5,0.025,0],[-2.1,-1.9],[-0.5,0.5],[-Inf,Inf]);
if ~ok, assertTrue(false,'Cuts from gen_sqw output and accumulate_sqw are not the same'), end

spe_accum={spe_file{1},'','',spe_file{4},spe_file{5},spe_file{6}};
accumulate_sqw (spe_accum, par_file, sqw_file_accum, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);
[ok,mess,w2_1456]=is_cut_equal(sqw_file_1456,sqw_file_accum,proj,[-1.5,0.025,0],[-2.1,-1.9],[-0.5,0.5],[-Inf,Inf]);
if ~ok, assertTrue(false,'Cuts from gen_sqw output and accumulate_sqw are not the same'), end

% Repeat a file
spe_accum={spe_file{1},'',spe_file{5},spe_file{4},spe_file{5},spe_file{6}};
try
    accumulate_sqw (spe_accum, par_file, sqw_file_accum, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);
    ok=false;
catch
    ok=true;
end
if ~ok, assertTrue(false,'Should have failed because of repeated spe file name'), end

% Repeat a file with 'replicate'
spe_accum={spe_file{1},'',spe_file{1},spe_file{4},spe_file{5},spe_file{6}};
accumulate_sqw (spe_accum, par_file, sqw_file_accum, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, 'replicate');
[ok,mess,w2_11456]=is_cut_equal(sqw_file_11456,sqw_file_accum,proj,[-1.5,0.025,0],[-2.1,-1.9],[-0.5,0.5],[-Inf,Inf]);
if ~ok, assertTrue(false,'Cuts from gen_sqw output and accumulate_sqw are not the same'), end

% Accumulate nothing:
spe_accum={spe_file{1},'',spe_file{1},spe_file{4},spe_file{5},spe_file{6}};
accumulate_sqw (spe_accum, par_file, sqw_file_accum, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, 'replicate');
[ok,mess]=is_cut_equal(sqw_file_11456,sqw_file_accum,proj,[-1.5,0.025,0],[-2.1,-1.9],[-0.5,0.5],[-Inf,Inf]);
if ~ok, assertTrue(false,'Cuts from gen_sqw output and accumulate_sqw are not the same'), end


%--------------------------------------------------------------------------------------------------
% Cleanup
%--------------------------------------------------------------------------------------------------
try
    for i=1:numel(spe_file)
        delete(spe_file{i})
    end
    for i=1:numel(spe_file)
        delete(sqw_file{i})
    end
    delete(sqw_file_14)
    delete(sqw_file_145623)
    delete(sqw_file_123456)
    delete(sqw_file_1456)
    delete(sqw_file_11456)
catch
    disp('Unable to delete temporary file(s)')
end

%% =====================================================================================================================
% Compare with saved output
% ====================================================================================================================== 
if ~save_output
    disp('====================================')
    disp('    Comparing with saved output')
    disp('====================================')
    output_file=fullfile(demo_dir,'test_gen_sqw_accumulate_sqw_output.mat');
    old=load(output_file);
    nam=fieldnames(old);
    tol=-1.0e-13;
    % The test proper
    for i=1:numel(nam)
        [ok,mess]=equal_to_tol(eval(nam{i}), old.(nam{i}), tol, 'min_denominator', 0.01, 'ignore_str', 1); if ~ok, assertTrue(false,['[',nam{i},']',mess]), end
    end    
    banner_to_screen([mfilename,': Test(s) passed'],'bot')
end


%% =====================================================================================================================
% Save data
% ====================================================================================================================== 
if save_output
    disp('===========================')
    disp('    Save output')
    disp('===========================')
    
    output_file=fullfile(tempdir,'test_gen_sqw_accumulate_sqw_output.mat');
    save(output_file, 'w1ref', 'w1a', 'w1b', 'w2_14', 'w2_1456', 'w2_11456');

    disp(' ')
    disp(['Output saved to ',output_file])
    disp(' ')
end
