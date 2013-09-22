function test_phx_par
% Test reading and writing of .par and .phx data

banner_to_screen(mfilename)

%--------------------------------------------------------------------------------------------------
group_2=[5 16 3 4 6 26 47 68 19 10];    % detector group numbers for det_2.par, det_2.phx

%--------------------------------------------------------------------------------------------------
% Read in par files
% -------------------------------
det1_par=read(parObject,'det_1.par');
det2_par=read(parObject,'det_2.par');   % non monotonic but valid detector group
det3_par=read(parObject,'det_3.par');   % all equal detector group

tmp=det1_par; tmp.group=group_2;
if ~equal_to_tol(tmp,det2_par,'ignore_str',1), error('Problem reading par files'), end

if ~equal_to_tol(det1_par,det3_par,'ignore_str',1), error('Problem reading par files'), end

try
    det4_par=read(parObject,'det_4.par');   % non-unique but not all the same detector group
    ok=false;
catch
    ok=true;
end
if ~ok, error('Did not catch expected error reading det_4.par'), end

% Save files, and read back in
% -------------------------------
save(det1_par,fullfile(tempdir,'det_1.par'));
save(det2_par,fullfile(tempdir,'det_2.par'));
save(det3_par,fullfile(tempdir,'det_3.par'));

det1_par_tmp=read(parObject,fullfile(tempdir,'det_1.par'));
det2_par_tmp=read(parObject,fullfile(tempdir,'det_2.par'));
det3_par_tmp=read(parObject,fullfile(tempdir,'det_3.par'));

if ~equal_to_tol(det1_par,det1_par_tmp,'ignore_str',1), error('Problem saving then reading par files'), end
if ~equal_to_tol(det2_par,det2_par_tmp,'ignore_str',1), error('Problem saving then reading par files'), end
if ~equal_to_tol(det3_par,det3_par_tmp,'ignore_str',1), error('Problem saving then reading par files'), end

%--------------------------------------------------------------------------------------------------
% Read in phx files
% -------------------------------
det1_phx=read(phxObject,'det_1.phx');
det2_phx=read(phxObject,'det_2.phx');   % non monotonic but valid detector group
det3_phx=read(phxObject,'det_3.phx');   % all equal detector group

tmp=det1_phx; tmp.group=group_2;
if ~equal_to_tol(tmp,det2_phx,'ignore_str',1), error('Problem reading phx files'), end

if ~equal_to_tol(det1_phx,det3_phx,'ignore_str',1), error('Problem reading phx files'), end

try
    det4_phx=read(phxObject,'det_4.phx');   % non-unique but not all the same detector group
    ok=false;
catch
    ok=true;
end
if ~ok, error('Did not catch expected error reading det_4.phx'), end


% Save files, and read back in
% -------------------------------
save(det1_phx,fullfile(tempdir,'det_1.phx'));
save(det2_phx,fullfile(tempdir,'det_2.phx'));
save(det3_phx,fullfile(tempdir,'det_3.phx'));

det1_phx_tmp=read(phxObject,fullfile(tempdir,'det_1.phx'));
det2_phx_tmp=read(phxObject,fullfile(tempdir,'det_2.phx'));
det3_phx_tmp=read(phxObject,fullfile(tempdir,'det_3.phx'));

if ~equal_to_tol(det1_phx,det1_phx_tmp,'ignore_str',1), error('Problem saving then reading phx files'), end
if ~equal_to_tol(det2_phx,det2_phx_tmp,'ignore_str',1), error('Problem saving then reading phx files'), end
if ~equal_to_tol(det3_phx,det3_phx_tmp,'ignore_str',1), error('Problem saving then reading phx files'), end

%--------------------------------------------------------------------------------------------------
% Test interconversion

x2=det2_par.x2;

tmp=phxObject(det2_par);
if ~equal_to_tol(det2_phx,tmp,-2e-5,'ignore_str',1), error('par=>phx conversion error'), end

tmp=parObject(det2_phx,x2);
if ~equal_to_tol(det2_par,tmp,-2e-5,'ignore_str',1), error('phx=>par conversion error'), end


%--------------------------------------------------------------------------------------------------
% Success announcement
% --------------------
disp(' ')
disp('Test(s) passed')
disp(' ')
