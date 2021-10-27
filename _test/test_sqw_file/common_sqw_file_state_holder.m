classdef common_sqw_file_state_holder < common_state_holder
    % Class holds the common states, to be set up for all tests in the 
    % folder and removed/restored when all tests are completed
    properties
    end
    
    methods
        function obj = common_sqw_file_state_holder()
            %
            obj@common_state_holder();
            count = obj.call_count();
            if count == 1
                % Swallow any warnings for when pixel page size set too small
                ws = struct('identifier',...
                    {'SQW_FILE:old_version','MATLAB:structOnObject'},...
                    'state',{'off','off'});
                old_sqw_file_warn_state = warning(ws);
                obj.store_holder(old_sqw_file_warn_state);
                %
            end
        end
        function delete(obj)
            delete@common_state_holder(obj);
            call_count = obj.call_count();
            if call_count == 0
                old_warn = obj.store_holder('','old_sqw_file_warn_state');
                warning(old_warn);
            end
        end
    end
end

