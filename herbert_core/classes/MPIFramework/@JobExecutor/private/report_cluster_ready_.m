function report_cluster_ready_(fbMPI, intercomm)
% When MPI framework was initialized, collect starting messages
% from all neighboring nodes and inform the server that the
% cluster have started.
%
%Inputs:
%fbMPI -- fully initialized file-based messages exchange
%         framework, used for communicating between cluster and
%         the Matlab session, which lounching it.
% intercomm -- fully initalized MPI framework, used for
%          communications between cluster's nodes
%
% Throws if all messages were not received within the time-out
% period
%

if intercomm.labIndex ==1
    mess = intercomm.receive_all('all','ready','-synch');
    id_s = cellfun(@(x)(x.payload),mess,'UniformOutput',true);
    the_mess = aMessage('ready');
    
    the_mess.payload = [1;id_s(:)];
    
    % report cluster started:
    [ok,err]=fbMPI.send_message(0,the_mess);
    if ok ~=MESS_CODES.ok
        error('MESS_FRAMEWORK:runtime_error',....
            ' Can not send filebased message "ready" to the control node. Reason: %s',...
            err);
    end
else
    mess = aMessage('ready');
    mess.payload = intercomm.labIndex;
    [ok,err]=intercomm.send_message(1,mess);
    if ok ~=MESS_CODES.ok
        error('MESS_FRAMEWORK:runtime_error',....
            ' Can not send message "ready" to the head-node. Reason: %s',...
            err);
    end
end
