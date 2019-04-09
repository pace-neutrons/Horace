function [all_ok,err,fin_message] = average_range_process_function_(all_messages,mess_name)
% the function which do actually calculates agerage range of all
% homogeneous messages
%
% Inputs:
% all_messages -- cellarray of messages, received from all labs, the data
%                 range is calculated
% mess_name    -- the name of the message, which should be received. If the
%                 names of some messages in the cellarray are different,
%                 its assumed that the average range of
%                 the cellarray is incorrect and fail message is returned
% Returns:
% all_ok        -- true if all messages in the cellarray are the requested messages
%                  false, if some messages names in all_messages list are
%                  different.
% err           -- string wich describes the reason for failure in more
%                  details if the all_ok == false or empty if true/
% fin_message   -- class of the type aMessage, containing the results of
%                  the function operations. This message will be send to
%                  the server
%
% $Revision:: 1750 ($Date:: 2019-04-09 10:04:04 +0100 (Tue, 9 Apr 2019) $)
%

ok = cellfun(@(x)(strcmpi(x.mess_name,mess_name)),all_messages,'UniformOutput',true);
all_ok = all(ok);
err = [];
all_payload = cellfun(@(x)(x.payload),all_messages,'UniformOutput',false);
if ~all_ok
    n_failed = sum(~ok);
    err = sprintf('GEN_SQW_FILES_JOB:runtime_error: %d workers have failed',...
        n_failed);
    fin_message = FailMessage(err);
    %all_payload(~ok) = all_messages(~ok);
    fin_message.payload = all_payload;
else
    fin_message = all_messages{1};
    urange = [Inf,Inf,Inf,Inf;-Inf,-Inf,-Inf,-Inf];
    grid_size = all_payload{1}.grid_size;
    for i=1:numel(all_payload)
        urange = [min(urange(1,:),all_payload{i}.urange(1,:));...
            max(urange(2,:),all_payload{i}.urange(2,:))];
        if any(grid_size ~=all_payload{i}.grid_size)
            error('GEN_SQW_FILES_JOB:runtime_error',...
                'a worker N%d calculates files with grid different from worker N1',...
                i)
        end
    end
    fin_message.payload = struct('urange',urange,'grid_size',grid_size);
end

