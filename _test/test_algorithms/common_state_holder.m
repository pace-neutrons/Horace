classdef common_state_holder < handle
    % Class holds the common states, to be removed/restored when all tests get
    % completed
    properties
    end
    
    methods
        function obj = common_state_holder()
            %
            count = obj.call_count('+');
            if count == 1
                % Swallow any warnings for when pixel page size set too small
                ws = struct('identifier',...
                    {'HORACE:PixelData:memory_allocation','LOAD_NXSPE:old_version'},...
                    'state',{'off','off'});
                old_warn_state = warning(ws);
                obj.store_holder(old_warn_state);
                %
            end
        end
        function delete(obj)
            call_count = obj.call_count('-');
            if call_count == 0
                old_warm = obj.store_holder('','old_warn_state');
                warning(old_warm);
            end
        end
    end
    methods (Static)
        function stor_val = store_holder(var_to_store,field_name)
            % provides persistent data storage
            persistent storage;
            if isempty(storage)
                storage = struct();
            end
            if ~exist('field_name','var')
                field_name= inputname(1);
            end
            if isempty(field_name)
                warning('Can not store variable without name. Nothing is stored');
                stor_val = '';
                return
            end
            
            if isfield(storage,field_name)
                stor_val = storage.(field_name);
            else
                stor_val  = '';
            end
            storage.(field_name) = var_to_store;
            
        end
        function count = call_count(direction)
            % return persistent call counter
            %
            % If called without arguments, reutrns current state of the
            % counter. If its the first call to the function, the value
            % will be 0;
            %
            % Optional inputs:
            % direction -- if '+' increnent and return counter
            %              if '-' decrement and return counter
            %              any other value -- return unchanged counter
            %
            persistent count_holder;
            if isempty(count_holder)
                count_holder = 0;
            end
            if exist('direction','var') && ischar(direction)
                if direction(1) == '+'
                    count_holder =  count_holder +1;
                elseif direction(1) == '-'
                    count_holder =  count_holder -1;
                end
            end
            count = count_holder;
        end
    end
end

