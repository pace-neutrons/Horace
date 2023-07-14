classdef common_pix_class_state_holder < common_state_holder
    % Class holds the common states, to be removed/restored when all tests get
    % completed
    properties
    end

    methods
        function obj = common_pix_class_state_holder()
            %
            obj = obj@common_state_holder();
            count = obj.call_count();
            if count == 1
                % keep mem_chunk_size and log level
                hc = hor_config;
                hor_config_to_store = hc.get_data_to_store();
                obj.store_holder(hor_config_to_store);
                %
            end
        end
        %
        function delete(obj)
            delete@common_state_holder(obj);
            call_count = obj.call_count();
            if call_count == 0
                old_conifg = obj.store_holder('','hor_config_to_store');
                hc = hor_config;
                set(hc ,old_conifg);
                hc.saveable = true;
            end
        end
    end
end

