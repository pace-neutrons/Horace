function [all_messages,mid_from] = list_all_messages_(obj,mess_addr_requested,mess_name_or_tag)
% list all messages sent to this task and retrieve the names
% for the lobs with id, provided as input.
%
% if no message is returned for a job, its name cell remains empty.
%
this_id  = obj.labIndex;
num_labs = obj.numLabs;
if exist('mess_addr_requested','var')
    if ischar(mess_addr_requested)
        if strcmpi(mess_addr_requested,'any')
            mess_addr_requested = 1:num_labs;
        else
            error('MESSAGES_MPI:invalid_argument',...
                'Unrecognized type of the message id requested to find in the system')
        end
    else
        mess_addr_requested = 1:num_labs; % list all available task_ids
    end
else
    mess_addr_requested = 1:num_labs; % take any message
end
to_this = mess_addr_requested ~=this_id; % remove messages directed to themselves
mess_addr_requested  = mess_addr_requested(to_this);
if isempty(mess_addr_requested ) %
    all_messages = {};
    mid_from = [];
    return;
end



if ~exist('mess_name_or_tag','var')
    mess_tag_requested = -1;
elseif ischar(mess_name_or_tag)
    if isempty(mess_name_or_tag)
        mess_tag_requested = -1;
    else
        mess_tag_requested = MESS_NAMES.mess_id(mess_name_or_tag);
    end
elseif isnumeric(mess_name_or_tag)
    is = MESS_NAMES.tag_valid(mess_name_or_tag);
    if is
        mess_tag_requested = mess_name_or_tag;
    else
        error('MESSAGES_MPI:invalid_argument',...
            'one all of the tags among the tags provided in tags list is not recognized')
    end
else
    error('MESSAGES_MPI:invalid_argument',...
        'unrecognized labProbe option')
end

mes_addr_to_check = uint32(mess_addr_requested);
mes_tag_to_check = int32(mess_tag_requested);

[obj.mpi_framework_holder_,addr_block] = cpp_communicator('labProbe',...
            obj.mpi_framework_holder_,mes_addr_to_check,mes_tag_to_check);
%        
if isempty(addr_block)
    all_messages = {};
    mid_from = [];    
else
    all_messages = MESS_NAMES.mess_name(addr_block(2,:));
    mid_from = addr_block(1,:);
end
