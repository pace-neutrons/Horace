function [ok,err_mess]=mpi_comm_tester(worker_controls_string)

err_mess = [];
ok = true;
if isempty(which('herbert_init.m'))
    horace_on();
end
me =MessagesCppMPI('test_MPI_job');
clob0 = onCleanup(@()finalize(me));
fname = sprintf('Log_file_for_labN%d#of%d.txt',me.labIndex,me.numLabs);
fh = fopen(fname,'w');
clob = onCleanup(@()fclose(fh));
fprintf(fh,'Lab N %d out of %d received control string: %s',...
    me.labIndex,me.numLabs,worker_controls_string);
pause(20)

end

