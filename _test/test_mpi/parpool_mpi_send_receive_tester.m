function [res,err] = parpool_mpi_send_receive_tester(job_control)
if isempty(which('horace_init'))
    horace_on();
end

nl = numlabs;
if nl > 1
    mis = MPI_State.instance();
    mis.is_deployed = true;    
end

pm = MessagesParpool('parpool_MPI_tester');


li = pm.labIndex;
id_send = li+1;
if id_send>nl
    id_send = id_send-nl;
end
id_receive = li -1;
if id_receive <1
    id_receive = id_receive+nl;
end
filepath = job_control.filepath;
fnt = job_control.filename_template;
fname = sprintf(fnt,li,nl);
file = fullfile(filepath,fname);
fileID = fopen(file,'w');
fprintf(fileID,'%s; numlabs: %d,labID: %d\n',fname,nl,li);
fclose(fileID);

mess = aMessage('started');
mess.payload = li*10;

[ok,err]  = pm.send_message(id_send,mess);
if ~ok
    res = -1;
    return
end
[ok,err,res] = pm.receive_message(id_receive);
if ~ok
    res = -2;
end
pm.clear_messages();


