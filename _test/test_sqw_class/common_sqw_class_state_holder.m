classdef common_sqw_class_state_holder < common_state_holder
    % Class holds the common states, to be removed/restored when all tests get
    % completed
    properties
    end

    methods
        function obj = common_sqw_class_state_holder()
            %
            obj = obj@common_state_holder();
            count = obj.call_count();
            if count == 1
                % Swallow any warnings for when pixel page size set too small
                ws = struct('identifier',...
                    {'SQW_FILE:old_version'},...
                    'state',{'off'});
                old_warn_state_sqw_class = warning(ws);
                obj.store_holder(old_warn_state_sqw_class);
                %
            end
        end
        %
        function delete(obj)
            delete@common_state_holder(obj);
            call_count = obj.call_count();
            if call_count == 0
                old_warn = obj.store_holder('','old_warn_state_sqw_class');
                warning(old_warn);
            end
        end
    end
end
