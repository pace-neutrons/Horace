function [err_code,err_mess,message] = receive_message_(obj,from_task_id,mess_name,varargin)
% Receive message from job with the task_id (MPI rank) specified
% if task_id is empty, or directly requests 'any', receive message from any task.
%
%
err_code = MESS_CODES.ok;
err_mess = [];
if ~exist('from_task_id','var') || ...
        (ischar(from_task_id) && strcmpi(from_task_id,'any')) || ...
        isempty(from_task_id)
    %receive message from any task
    error('MESSAGES_FRAMEWORK:invalid_argument',...
        'Requesting receive message from undefined lab is not currently supported');
end
if ~isnumeric(from_task_id)
    error('MESSAGES_FRAMEWORK:invalid_argument',...
        'Task_id to receive message should be a number');
end

if ~exist('mess_name','var') %receive any message for this task
    mess_name = 'any';
end
if ~ischar(mess_name)
    error('MESSAGES_FRAMEWORK:invalid_argument',...
        'mess_name in recive_message command should be a message name (e.g. "starting")');
    
end
if (from_task_id<1 || from_task_id > obj.numLabs)
    error('MESSAGES_FRAMEWORK:invalid_argument',...
        'The message requested from worker N%d but can be only received from workers in range [1:%d]',...
        from_task_id,obj.numLabs);
end

message = obj.get_interrupt(from_task_id);
if ~isempty(message);   return; end


mess_tag = MESS_NAMES.mess_id(mess_name);
if nargin>3
    [ok,mess,synch,asynch]=parse_char_options(varargin,{'-synchronous','-asynchronous'});
    if ~ok
        error('MESSAGES_FRAMEWORK:invalid_argument',mess);
    end
    if synch && asynch
        error('MESSAGES_FRAMEWORK:invalid_argument',...
            'Both -synchronous and -asynchronous options are provided as input. Only one is allowed');
    end
    if synch
        is_blocking = true;        
    elseif asynch
        is_blocking = false;
    else
        is_blocking = MESS_NAMES.is_blocking(mess_name);
    end
else
    is_blocking = MESS_NAMES.is_blocking(mess_name);
end


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
    message  = [];
else
    message = hlp_deserialize(mess_data);
end
obj.set_interrupt(message,from_task_id);
