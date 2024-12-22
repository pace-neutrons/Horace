% Two different spe files corresponding to two different detector arrays
% - fm_simple_cubic_a.spe   with   det_a.par
% - fm_simple_cubic_b.spe   with   det_b.par
% with a standard cut

% Run, instrument and sample information
% --------------------------------------
efix = 36;
emode = 1;
alatt = [4,4,4];
angdeg = [90,90,90];
u = [1,0,0];
v = [0,1,0];
psi = 45;
omega = 0; dpsi = 0; gl=0; gs=0;

instru = maps_instrument (efix, 250, 's');
sample = IX_sample (true, [1,0,0], [0,1,0], 'cuboid',[0.04,0.03,0.02]);


%% =============================================================================
% Run gen_sqw on .spe files
% ==============================================================================

% -----------------------------------------------------------
% Create sqw files from each spe file in isolation
% -----------------------------------------------------------
spe_file_a = 'fm_simple_cubic_a.spe';
par_file_a = 'det_a.par';
sqw_file_a_from_spe = fullfile(tmp_dir(),'fm_simple_cubic_a_from_spe.sqw');

gen_sqw (spe_file_a, par_file_a, sqw_file_a_from_spe, efix, emode, alatt, angdeg, u, v, psi, ...
    omega, dpsi, gl, gs, instru, sample);

spe_file_b = 'fm_simple_cubic_b.spe';
par_file_b = 'det_b.par';
sqw_file_b_from_spe = fullfile(tmp_dir(),'fm_simple_cubic_b_from_spe.sqw');

gen_sqw (spe_file_b, par_file_b, sqw_file_b_from_spe, efix, emode, alatt, angdeg, u, v, psi, ...
    omega, dpsi, gl, gs, instru, sample);

spe_file_ab = 'fm_simple_cubic_ab.spe';
par_file_ab = 'det_ab.par';
sqw_file_ab_from_spe = fullfile(tmp_dir(),'fm_simple_cubic_ab_from_spe.sqw');

gen_sqw (spe_file_ab, par_file_ab, sqw_file_ab_from_spe, efix, emode, alatt, angdeg, u, v, psi, ...
    omega, dpsi, gl, gs, instru, sample);


% Read sqw files
% --------------
wa_from_spe = read_sqw (sqw_file_a_from_spe);  % read sqw file
wb_from_spe = read_sqw (sqw_file_b_from_spe);  % read sqw file
wab_from_spe = read_sqw (sqw_file_ab_from_spe);  % read sqw file


% Take standard cut
% -----------------
proj = line_proj ([1,-1,0],[1,1,0]);

wa1_from_spe = cut (wa_from_spe, proj, [0.45,0.55], [-1,0.015,1], [-1,1], [0,33]);
wb1_from_spe = cut (wb_from_spe, proj, [0.45,0.55], [-1,0.015,1], [-1,1], [0,33]);
wab1_from_spe = cut (wab_from_spe, proj, [0.45,0.55], [-1,0.015,1], [-1,1], [0,33]);

clearfigs
acolor k; dd(wa1_from_spe); keep_figure
acolor k; dd(wb1_from_spe); keep_figure
acolor k; dd(wab1_from_spe); keep_figure


% -----------------------------------------------------------
% Attempt to create a single sqw file from the two .spe files 
% fm_simple_cubic_a.spe and fm_simple_cubic_b.spe
% -----------------------------------------------------------
% These have different detector parameters. The call to gen_sqw fails however:
spe_files = {'fm_simple_cubic_a.spe', 'fm_simple_cubic_b.spe'};
par_files = {'det_a.par', 'det_b.par'};
sqw_file_from_spe = fullfile(tmp_dir(),'fm_simple_cubic_from_spe.sqw');

gen_sqw (spe_files, par_files, sqw_file_from_spe, efix, emode, alatt, angdeg, u, v, psi, ...
    omega, dpsi, gl, gs, instru, sample);

waplusb = read_sqw(sqw_file_from_spe);
disp(''); % stopping point for debugging



%% =============================================================================
% Run gen_sqw on .nxspe files
% ==============================================================================

% -----------------------------------------------------------
% Create sqw files from each nxspe file in isolation
% -----------------------------------------------------------
nxspe_file_a = 'fm_simple_cubic_a.nxspe';
sqw_file_a_from_nxspe = fullfile(tmp_dir(),'fm_simple_cubic_a_from_nxspe.sqw');
gen_sqw (nxspe_file_a, [], sqw_file_a_from_nxspe, efix, emode, alatt, angdeg, u, v, psi, ...
    omega, dpsi, gl, gs, instru, sample);

nxspe_file_b = 'fm_simple_cubic_b.nxspe';
sqw_file_b_from_nxspe = fullfile(tmp_dir(),'fm_simple_cubic_b_from_nxspe.sqw');
gen_sqw (nxspe_file_b, [], sqw_file_b_from_nxspe, efix, emode, alatt, angdeg, u, v, psi, ...
    omega, dpsi, gl, gs, instru, sample);

nxspe_file_ab = 'fm_simple_cubic_ab.nxspe';
sqw_file_ab_from_nxspe = fullfile(tmp_dir(),'fm_simple_cubic_ab_from_nxspe.sqw');
gen_sqw (nxspe_file_ab, [], sqw_file_ab_from_nxspe, efix, emode, alatt, angdeg, u, v, psi, ...
    omega, dpsi, gl, gs, instru, sample);


% Read sqw files
% --------------
wa_from_nxspe = read_sqw (sqw_file_a_from_nxspe);  % read sqw file
wb_from_nxspe = read_sqw (sqw_file_b_from_nxspe);  % read sqw file
wab_from_nxspe = read_sqw (sqw_file_ab_from_nxspe);  % read sqw file

proj = line_proj ([1,-1,0],[1,1,0]);

wa1_from_nxspe = cut (wa_from_nxspe, proj, [0.45,0.55], [-1,0.015,1], [-1,1], [0,33]);
wb1_from_nxspe = cut (wb_from_nxspe, proj, [0.45,0.55], [-1,0.015,1], [-1,1], [0,33]);
wab1_from_nxspe = cut (wab_from_nxspe, proj, [0.45,0.55], [-1,0.015,1], [-1,1], [0,33]);

clearfigs
acolor k; dd(wa1_from_spe); acolor r; pd(wa1_from_nxspe+0.001); keep_figure
acolor k; dd(wb1_from_spe); acolor r; pd(wb1_from_nxspe+0.001); keep_figure
acolor k; dd(wab1_from_spe); acolor r; pd(wab1_from_nxspe+0.001); keep_figure


% -----------------------------------------------------------
% Attempt to create a single sqw file from the two .spe files 
% fm_simple_cubic_a.spe and fm_simple_cubic_b.spe
% -----------------------------------------------------------

% These have different detector parameters. The call to gen_sqw fails however:
nxspe_files = {'fm_simple_cubic_a.nxspe', 'fm_simple_cubic_b.nxspe'};
sqw_file_from_nxspe = fullfile(tmp_dir(),'fm_simple_cubic_from_nxspe.sqw');

gen_sqw (nxspe_files, [], sqw_file_from_nxspe, efix, emode, alatt, angdeg, u, v, psi, ...
    omega, dpsi, gl, gs, instru, sample);
