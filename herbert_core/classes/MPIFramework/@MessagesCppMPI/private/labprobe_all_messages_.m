function [mess_names,tid_from] = labprobe_all_messages_(obj,mess_addr_requested,mess_name_or_tag)
% list all messages sent to this task and retrieve the names
% for the lobs with id, provided as input.
%
% if no message is returned for a job, its name cell remains empty.
%
this_id  = obj.labIndex;
num_labs = obj.numLabs;
if exist('mess_addr_requested', 'var')
    if ischar(mess_addr_requested)
        if strcmpi(mess_addr_requested,'all') || isempty(mess_addr_requested)
            mess_addr_requested = 1:num_labs;
        else
            error('MESSAGES_FRAMEWORK:invalid_argument',...
                'Unrecognized type of the task id: %s requested to check for message',...
                mess_addr_requested)
        end
    elseif ~isnumeric(mess_addr_requested)
        error('MESSAGES_FRAMEWORK:invalid_argument',...
            'Unrecognized type of the task id: %s requested to ask for message',...
            evalc('disp(mess_addr_requested)'));
    end
    if isempty(mess_addr_requested)
        mess_addr_requested = 1:num_labs;
    end
else
    mess_addr_requested = 1:num_labs; % take any message
end
to_this = mess_addr_requested ~=this_id; % remove messages directed to themselves
mess_addr_requested  = mess_addr_requested(to_this);
if isempty(mess_addr_requested ) %
    mess_names = {};
    tid_from = [];
    return;
end


if ~exist('mess_name_or_tag', 'var') || isempty(mess_name_or_tag)
    mess_tag_requested = -1;
elseif ischar(mess_name_or_tag)
    if strcmp(mess_name_or_tag,'any')
        mess_tag_requested = -1;
    else
        mess_tag_requested = MESS_NAMES.mess_id(mess_name_or_tag,obj.interrupt_chan_tag_);
    end
elseif isnumeric(mess_name_or_tag)
    if mess_name_or_tag ~= obj.interrupt_chan_tag_
        is = MESS_NAMES.tag_valid(mess_name_or_tag);
        if is
            mess_tag_requested = mess_name_or_tag;
        else
            error('MESSAGES_FRAMEWORK:invalid_argument',...
                'one all of the tags among the tags provided in tags list is not recognized')
        end
    else
        mess_tag_requested  = obj.interrupt_chan_tag_;
    end
else
    error('MESSAGES_FRAMEWORK:invalid_argument',...
        'unrecognized labProbe option')
end

mes_addr_to_check = uint32(mess_addr_requested);
mes_tag_to_check = int32(mess_tag_requested);
%
% will also check for interrupt messages internally and return them instead
% requested if any available.
[obj.mpi_framework_holder_,addr_block] = cpp_communicator('labProbe',...
    obj.mpi_framework_holder_,mes_addr_to_check,mes_tag_to_check);
%
if isempty(addr_block)
    mess_names = {};
    tid_from = [];
else
    tid_from = addr_block(1,:);
    [tid_from,itu] = unique(tid_from);
    % if numel(tid_from) ~= numel(tid_unique) % interrupts present alongside
    % the messages.
    % In any case, the interrupts will be asked for first, so will be
    % first in the responce array. Only interrups will be selected
    tags  = addr_block(2,itu);
    mess_names = MESS_NAMES.mess_name(tags,obj.interrupt_chan_tag_);
    if ~iscell(mess_names)
        mess_names  = {mess_names};
    end
end

% add persistent messages names already received to the messages,
% received from other labs
[mess,id_from] = obj.get_interrupt(mess_addr_requested);
% mix received messages names with old interrupt names received earlier and
% hold in cache
if ~isempty(mess)
    int_names = cellfun(@(x)(x.mess_name),mess,'UniformOutput',false);
    [mess_names,tid_from] = ...
        obj.mix_messages(mess_names,tid_from,int_names,id_from);
end
if numel(tid_from) == 1
    if ischar(mess_names)
        mess_names = {mess_names};
    end
end
tid_from = double(tid_from);
