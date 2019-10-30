function [ok,err_mess]=mpi_comm_tester(worker_controls_string)


err_mess = [];
ok = true;
if isempty(which('herbert_init.m'))
    horace_on();
end
me =MessagesCppMPI('test_MPI_job');

labInd = me.labIndex;
numLabs = me.numLabs;
%clob0 = onCleanup(@()finalize_all(me));
fname = sprintf('Log_file_for_labN%d#of%d.txt',labInd,numLabs);
fh = fopen(fname,'w');
clob = onCleanup(@()fclose(fh));
fprintf(fh,'Lab N %d out of %d received control string: %s',...
    labInd,numLabs,worker_controls_string);
disp('file written, entering pause')
pause(10)
%comm=cpp_communicator('finalize',comm);
me.finalize_all()
end

