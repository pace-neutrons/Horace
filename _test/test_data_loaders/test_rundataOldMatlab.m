function  test_rundataOldMatlab()
%The test written in a way, it can run by old matlab and the new one (using
%xUnittests to verify brifely old matlab consistency.
%run=rundata();
pths = horace_paths;


log_level = get(hor_config,'log_level');
set(hor_config,'log_level',-1,'-buffer');
cleanupObj = onCleanup(@() set(hor_config,'log_level',log_level,'-buffer'));

run=rundata(fullfile(pths.test_common,'MAP10001.spe'),fullfile(pths.test_common,'demo_par.PAR'));
run.efix = 200;
run=get_rundata(run,'-this');
assertTrue(run.isvalid)
assertEqual(run.efix,200)

run=rundata(fullfile(pths.test_common,'MAP11014.nxspe'));
run.efix = 200;
run=get_rundata(run,'-this');
assertFalse(run.isvalid)
assertEqual(run.efix,200)
