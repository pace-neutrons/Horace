function [err_code,err_mess,mess] = receive_message_(obj,from_task_id,mess_name,varargin)
% Receive message from job with the task_id (MPI rank) specified as input
% if mess_name == 'any', receive any tag.
%
err_code = MESS_CODES.ok;
err_mess = [];

if any(from_task_id==0)
    error('MESSAGES_FRAMEWORK:invalid_argument',...
        'CPP messages framework can not communicate with lab 0')
end

mess = obj.get_interrupt(from_task_id);
if ~isempty(mess)
    err_code  =MESS_CODES.ok;
    err_mess=[];
    return;
end
%
mess_tag = MESS_NAMES.mess_id(mess_name,obj.interrupt_chan_tag_);
% identify the way of receiving message. Like MessagesParpool, if 
% interrupts appears after the framework starts waiting for data message 
% synchronously, the framework hangs up, so Receive_all should be used to 
% avoid such hang ups. From other side, this situation is not important as
% MPI framerowk will fail on parallel interrupt
if mess_tag == obj.interrupt_chan_tag_
    is_blocking = false;
else
    if nargin>3
        is_blocking = varargin{1};
    else
        is_blocking = MESS_NAMES.is_blocking(mess_name);
    end
end

% C++ code checks for interrupt internaly, so no checks in Matlab code is
% necessary
try
    [obj.mpi_framework_holder_,mess_data]=cpp_communicator('labReceive',...
        obj.mpi_framework_holder_,int32(from_task_id),int32(mess_tag),...
        uint8(is_blocking));
catch ERR
    if strcmpi(ERR.identifier,'MPI_MEX_COMMUNICATOR:runtime_error')
        error('MESSAGES_FRAMEWORK:runtime_error',...
            'synchroneous waiting in test mode is not allowed')
    else
        rethrow(ERR);
    end
end
if isempty(mess_data) % no message present at asynchronous receive.
    mess  = [];
else
    mess = deserialize(mess_data);
end
obj.set_interrupt(mess,from_task_id);
